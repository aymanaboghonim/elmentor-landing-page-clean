import os
import shutil
from pathlib import Path

def copy_assets():
    # Define paths
    original_base = Path(r"d:\Github_personal\elmentor-landing-page")
    clean_base = Path(r"d:\Github_personal\elmentor-landing-page-clean")
    
    # Asset copy mappings: (source_path, dest_path)
    assets_to_copy = [
        # Logo files
        (original_base / "src/assets/images/elmentor-logo.png", 
         clean_base / "src/assets/images/elmentor-logo.png"),
        
        # Founder image
        (original_base / "src/assets/images/mohamed-radwan.png", 
         clean_base / "src/assets/images/mohamed-radwan.png"),
        
        # Circles diagram
        (original_base / "public/elmentor-circles.png", 
         clean_base / "public/elmentor-circles.png"),
        
        # DevOps Visions logos
        (original_base / "src/assets/images/DevOps-Visions.png", 
         clean_base / "src/assets/images/DevOps-Visions.png"),
        
        (original_base / "src/assets/images/DevOps-Visions_Horizontal_Green.png", 
         clean_base / "src/assets/images/DevOps-Visions_Horizontal_Green.png"),
    ]
    
    print("🚀 Starting asset copy process...")
    success_count = 0
    error_count = 0
    
    for source, dest in assets_to_copy:
        try:
            if source.exists():
                # Create destination directory if it doesn't exist
                dest.parent.mkdir(parents=True, exist_ok=True)
                
                # Copy the file
                shutil.copy2(source, dest)
                print(f"✅ Copied: {source.name}")
                success_count += 1
            else:
                print(f"❌ Source not found: {source}")
                error_count += 1
                
        except Exception as e:
            print(f"❌ Error copying {source.name}: {str(e)}")
            error_count += 1
    
    print(f"\n📊 Results: ✅ {success_count} copied, ❌ {error_count} failed")
    
    if success_count > 0:
        print("🎉 Assets copied successfully! Website should now display all images.")

if __name__ == "__main__":
    copy_assets()
