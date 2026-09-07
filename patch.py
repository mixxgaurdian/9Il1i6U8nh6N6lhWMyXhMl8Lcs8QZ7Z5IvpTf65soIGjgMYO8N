import os
import shutil

file_path = r'c:\Users\alici\Desktop\R-Loader\projects\obfuscate.py'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace(
    'self.output_path_var = ctk.StringVar()',
    'self.output_path_var = ctk.StringVar()\n        self.output_filename_var = ctk.StringVar()'
)

ui_insertion = '''        self.create_path_row(path_frame, "Custom Output Path:", self.output_path_var, self.browse_output)

        # New row for custom filename
        name_row = ctk.CTkFrame(path_frame, fg_color="transparent")
        name_row.pack(fill="x", padx=10, pady=5)
        ctk.CTkLabel(name_row, text="Output Filename:", width=130, anchor="w").pack(side="left")
        name_entry = ctk.CTkEntry(name_row, textvariable=self.output_filename_var, placeholder_text="Leave blank to use original name (strips .source automatically)")
        name_entry.pack(side="left", fill="x", expand=True, padx=5)
'''
content = content.replace(
    '        self.create_path_row(path_frame, "Custom Output Path:", self.output_path_var, self.browse_output)',
    ui_insertion
)

logic_old = '''        else:
            # Move to custom output path, stripping the ".obfuscated" tag so it keeps its original name in the new folder
            final_custom_path = os.path.join(output_dir, f"{base_name}{ext}")
            shutil.move(obfuscated_file_path, final_custom_path)'''

logic_new = '''        else:
            # Get custom filename or auto-strip .source
            custom_filename = self.output_filename_var.get().strip()
            if not custom_filename:
                clean_base = base_name.replace(".source", "")
                custom_filename = f"{clean_base}{ext}"
                
            final_custom_path = os.path.join(output_dir, custom_filename)
            shutil.move(obfuscated_file_path, final_custom_path)'''
            
content = content.replace(logic_old, logic_new)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
print('Patched successfully!')
