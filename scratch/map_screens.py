import os
import re

base_dir = r"C:\engener\stitch_elite_global_ui_design\stitch_elite_global_ui_design"
subdirs = [d for d in os.listdir(base_dir) if os.path.isdir(os.path.join(base_dir, d))]

# sort naturally
subdirs.sort(key=lambda x: int(x[1:]) if x.startswith('_') and x[1:].isdigit() else 99)

out_lines = []
for s in subdirs:
    p = os.path.join(base_dir, s, "code.html")
    if os.path.exists(p):
        with open(p, 'r', encoding='utf-8') as f:
            content = f.read()
            title = re.search(r"<title>(.*?)</title>", content, re.IGNORECASE)
            title_text = title.group(1).strip() if title else "NO TITLE"
            
            # Find headings
            headings = re.findall(r"<h[1-3][^>]*>(.*?)</h[1-3]>", content, re.IGNORECASE)
            clean_headings = []
            for h in headings:
                clean_h = re.sub(r"<[^>]*>", "", h).strip()
                clean_headings.append(clean_h)
                
            out_lines.append(f"Folder {s}:")
            out_lines.append(f"  Title: {title_text}")
            out_lines.append(f"  Headings: {', '.join(clean_headings[:8])}")
            out_lines.append("-" * 50)

with open(r"C:\engener\scratch\mapped_screens.txt", "w", encoding="utf-8") as out_f:
    out_f.write("\n".join(out_lines))
print("Done writing mapping file.")
