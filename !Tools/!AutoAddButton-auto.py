"""
AHK-FOR-RPM | Tools

Tool for auto rewrite scripts for AHK-FOR-RPM v2

t := ui.AddButton("w250 h30 y+5 x5", "Label")
CreateImageButton(t, 0, ButtonStyles["binds"]*)
t.OnEvent("Click", function)

  |
 \_/

AutoAddButton(ui, "Label", function, "full")
"""

input_text = """

"""

import re

def transform_buttons_from_text(text):
    output_lines = []
    
    lines = [line.strip() for line in text.strip().splitlines() if line.strip()]
    
    if len(lines) % 3 != 0:
        print("The number of non-empty lines is not a multiple of 3. Some blocks may be incomplete.")

    addbutton_regex = re.compile(r't\s*:=\s*(\w+)\.AddButton\(\s*([^,]+),\s*"([^"]+)"\)')
    onevent_regex = re.compile(r't\.OnEvent\("Click",\s*(\w+)\)')
    
    for idx in range(0, len(lines), 3):
        block = lines[idx:idx+3]
        if len(block) < 3:
            continue 
        
        addbutton_line = block[0]
        onevent_line = block[2]
        
        add_match = addbutton_regex.search(addbutton_line)
        if not add_match:
            print(f"Could not parse AddButton line: {addbutton_line}")
            continue
        
        ui_object = add_match.group(1)
        config_text = add_match.group(2) 
        label = add_match.group(3)
        
        event_match = onevent_regex.search(onevent_line)
        if not event_match:
            print(f"Could not parse OnEvent line: {onevent_line}")
            continue
        callback = event_match.group(1)
        

        if "w250" in config_text:
            style = "full"
        elif "w123" in config_text:
            if "t.Y" in config_text:
                style = "mini2"
            else:
                style = "mini1"
        else:
            style = "full"
        
        transformed_line = f'AutoAddButton({ui_object}, "{label}", {callback}, "{style}")'
        output_lines.append(transformed_line)
    
    return output_lines

def main():
    transformed_lines = transform_buttons_from_text(input_text)
    for line in transformed_lines:
        print(line)

if __name__ == "__main__":
    main()
