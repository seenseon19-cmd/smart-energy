import os

def search_text(directory, keyword):
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.dart'):
                path = os.path.join(root, file)
                try:
                    with open(path, 'r', encoding='utf-8') as f:
                        lines = f.readlines()
                        for idx, line in enumerate(lines):
                            if keyword.lower() in line.lower():
                                print(f"{file}:{idx+1}: {line.strip()}")
                except Exception as e:
                    pass

print("Searching for ESP32:")
search_text(r"C:\engener\lib", "esp")
print("Searching for dialog or modal:")
search_text(r"C:\engener\lib", "dialog")
