from PIL import Image
import os

# Define the input icon image path
input_icon_path = "expense_tracker.png"

# Define the output directory for different densities
output_directory = "android/app/src/main/res"

# Define the sizes for different densities (in pixels)
sizes = {
    "mdpi": 48,
    "hdpi": 72,
    "xhdpi": 96,
    "xxhdpi": 144,
    "xxxhdpi": 192
}

# Open the input icon image
input_image = Image.open(input_icon_path)

# Loop through different densities and resize the image
for density, size in sizes.items():
    # Create the output directory if it doesn't exist
    output_path = os.path.join(output_directory, f"mipmap-{density}")
    os.makedirs(output_path, exist_ok=True)

    # Resize the image and save it
    output_image = input_image.resize((size, size), Image.ANTIALIAS)
    output_image.save(os.path.join(output_path, "ic_launcher.png"))

print("Icon images resized and saved.")
