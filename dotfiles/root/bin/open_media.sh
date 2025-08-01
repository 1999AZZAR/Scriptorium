#!/bin/bash

# --- Configuration ---
IMAGE_VIEWER="org.kde.gwenview.desktop"
VIDEO_PLAYER="org.kde.haruna.desktop"

# --- Common Image MIME Types ---
IMAGE_MIMES="
image/jpeg
image/png
image/gif
image/bmp
image/webp
image/tiff
image/svg+xml
image/x-canon-cr2
image/x-nikon-nef
image/heic
image/heif
image/avif
"

# --- Common Video MIME Types ---
VIDEO_MIMES="
video/mp4
video/x-matroska
video/webm
video/quicktime
video/x-msvideo
video/x-flv
video/x-ms-wmv
video/mpeg
"

# --- Applying Defaults ---
echo "Setting default image viewer to $IMAGE_VIEWER..."
for mime in $IMAGE_MIMES; do
  xdg-mime default $IMAGE_VIEWER $mime
done

echo "Setting default video player to $VIDEO_PLAYER..."
for mime in $VIDEO_MIMES; do
  xdg-mime default $VIDEO_PLAYER $mime
done

echo "✅ All done!"
#!/bin/bash

# --- Configuration ---
IMAGE_VIEWER="org.kde.gwenview.desktop"
VIDEO_PLAYER="org.kde.haruna.desktop"

# --- Common Image MIME Types ---
IMAGE_MIMES="
image/jpeg
image/png
image/gif
image/bmp
image/webp
image/tiff
image/svg+xml
image/x-canon-cr2
image/x-nikon-nef
image/heic
image/heif
image/avif
"

# --- Common Video MIME Types ---
VIDEO_MIMES="
video/mp4
video/x-matroska
video/webm
video/quicktime
video/x-msvideo
video/x-flv
video/x-ms-wmv
video/mpeg
"

# --- Applying Defaults ---
echo "Setting default image viewer to $IMAGE_VIEWER..."
for mime in $IMAGE_MIMES; do
  xdg-mime default $IMAGE_VIEWER $mime
done

echo "Setting default video player to $VIDEO_PLAYER..."
for mime in $VIDEO_MIMES; do
  xdg-mime default $VIDEO_PLAYER $mime
done

echo "✅ All done!"
