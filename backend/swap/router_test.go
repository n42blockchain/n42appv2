package main

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
)

func TestCORSMiddlewareAllowsOnlyConfiguredOrigins(t *testing.T) {
	gin.SetMode(gin.TestMode)
	t.Setenv("CORS_ORIGINS", "https://app.example, https://admin.example")
	router := gin.New()
	router.Use(corsMiddleware())
	router.GET("/resource", func(c *gin.Context) { c.Status(http.StatusOK) })

	allowed := httptest.NewRecorder()
	request := httptest.NewRequest(http.MethodGet, "/resource", nil)
	request.Header.Set("Origin", "https://app.example")
	router.ServeHTTP(allowed, request)
	if allowed.Code != http.StatusOK || allowed.Header().Get("Access-Control-Allow-Origin") != "https://app.example" {
		t.Fatalf("allowed origin response = %d %#v", allowed.Code, allowed.Header())
	}
	if allowed.Header().Get("Access-Control-Allow-Headers") != "Content-Type, Authorization" {
		t.Fatalf("missing allowed headers: %#v", allowed.Header())
	}

	denied := httptest.NewRecorder()
	request = httptest.NewRequest(http.MethodGet, "/resource", nil)
	request.Header.Set("Origin", "https://evil.example")
	router.ServeHTTP(denied, request)
	if denied.Code != http.StatusOK || denied.Header().Get("Access-Control-Allow-Origin") != "" {
		t.Fatalf("unconfigured origin was allowed: %d %#v", denied.Code, denied.Header())
	}
}

func TestCORSMiddlewareStopsPreflight(t *testing.T) {
	gin.SetMode(gin.TestMode)
	t.Setenv("CORS_ORIGINS", "https://app.example")
	called := false
	router := gin.New()
	router.Use(corsMiddleware())
	router.OPTIONS("/resource", func(c *gin.Context) { called = true })
	response := httptest.NewRecorder()
	request := httptest.NewRequest(http.MethodOptions, "/resource", nil)
	request.Header.Set("Origin", "https://app.example")
	router.ServeHTTP(response, request)
	if response.Code != http.StatusNoContent || called {
		t.Fatalf("preflight response=%d downstreamCalled=%t", response.Code, called)
	}
	if response.Header().Get("Access-Control-Max-Age") != "86400" {
		t.Fatalf("preflight max-age missing: %#v", response.Header())
	}
}

func TestSetupRouterHealthCheck(t *testing.T) {
	gin.SetMode(gin.TestMode)
	t.Setenv("CORS_ORIGINS", "")
	router := setupRouter(nil, nil, nil, nil, nil)
	response := httptest.NewRecorder()
	router.ServeHTTP(response, httptest.NewRequest(http.MethodGet, "/health", nil))
	if response.Code != http.StatusOK || response.Body.String() != `{"status":"ok"}` {
		t.Fatalf("health response = %d %q", response.Code, response.Body.String())
	}
}
