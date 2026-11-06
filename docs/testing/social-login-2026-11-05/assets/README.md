# Meta app icon

`n42-facebook-transparent.png` is an alpha-channel PNG derived with the built-in
image_gen tool from `ios/Runner/Assets.xcassets/AppIcon.appiconset/1024.png`.
It is a separate Meta asset; the shipped native app icon was not changed.
Meta accepted the upload and saved it. After reload, the missing-icon requirement
was gone. Other publication requirements remain outstanding.

Prompt: Edit the supplied existing N42 Wallet app logo. Only remove the white
background and its pale blue ambient halo outside the outer blue silhouette,
replacing them with actual transparent alpha. Preserve the exact original colorful
concentric asymmetric circular logo, shape, internal blue cyan purple magenta
yellow colors and shading, same size and center position, same 1024x1024 square
canvas and margins. No redesign, no text, no new outline, no checkerboard painted
into pixels. Export a PNG with transparent background suitable for the Meta app icon.

Output was 1254x1254 with alpha; Meta's crop/upload workflow accepted it.
