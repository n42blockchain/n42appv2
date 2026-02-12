///加载数据状态
enum Load{
  loading,//正在加载
  finish,//加载完成
  error,//加载失败
  refresh,//刷新，下拉刷新
  nextPage,//加载更多
}