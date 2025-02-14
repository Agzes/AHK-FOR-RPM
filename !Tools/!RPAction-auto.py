"""
AHK-FOR-RPM | Tools

Tool for auto rewrite scripts for AHK-FOR-RPM v2

SendInput("{t}")
Sleep(100)
SendInput("/mee взяв тару и бутылку с водой из шкафа, наливает воду из бутылки в тару{ENTER}")
Sleep(1850) ;
SendInput("{t}")
Sleep(1850)
SendInput("/mee берет гипсовый бинт, вскрывает пачку и начинает раскладывать на столе в 6 слоев по одинаковому размеру, скрутив с двух сторон опускает на 3 секунды в воду{ENTER}")
Sleep(1850) ;
SendInput("{t}")
Sleep(1850)
SendInput("/mee отжав лишнюю воду с бинтов, раскладывает на столе и  разглаживает гипсовый бинт{ENTER}")
Sleep(1850) ;
SendInput("{t}")
Sleep(1850)
SendInput("/mee взяв двумя руками бинт прикладывает на место перелома, формирует и разглаживает края{ENTER}")
Sleep(1850) ;
SendInput("{t}")
Sleep(1850)
SendInput("/mee подождав пару минут, проверяет подсыхание гипса надавив пальцами с краю, затем берёт бинт и начинает обматывать гипс, закрепляет конец бинта{ENTER}")
Sleep(4000) ;
SendInput("{t}")
Sleep(1850)
SendInput("/todo Передавая костыли пациенту : Через 3 недели снимем гипс.{ENTER}")

 |
\_/

RpAction([
    ["Chat", "...", S1000, S1000]
    ...
])

"""

import re


input_text = r""" 
"""


def extract_events(text):
    sleep_pattern = re.compile(r"Sleep\(\s*([^)\s]+)\s*\)")
    send_pattern = re.compile(r'SendInput\(\s*"([^"]+)"\s*\)')

    events = []
    for line in text.splitlines():
        line = line.strip()
        if not line:
            continue
        sleep_match = sleep_pattern.search(line)
        if sleep_match:
            events.append(("sleep", sleep_match.group(1)))
        send_match = send_pattern.search(line)
        if send_match:
            message = send_match.group(1)
            events.append(("send", message))
    return events


def pair_action_events(events):
    actions = []
    i = 0
    n = len(events)
    while i < n:
        typ, val = events[i]
        if typ == "send" and val != "{t}":
            pre_sleep = None
            post_sleep = None
            j = i - 1
            while j >= 0:
                if events[j][0] == "sleep":
                    pre_sleep = events[j][1]
                    break
                j -= 1
            j = i + 1
            while j < n:
                if events[j][0] == "sleep":
                    post_sleep = events[j][1]
                    break
                j += 1
            if pre_sleep is not None and post_sleep is not None:
                actions.append((val, pre_sleep, post_sleep))
        i += 1
    return actions


def transform_function_block(block_text):
    header_match = re.search(r"^(?P<header>\w+\s*\([^)]*\))", block_text, re.MULTILINE)
    if header_match:
        header = header_match.group("header").strip()
    else:
        header = "unknown_function"

    body_match = re.search(r"\{(.*)\}\s*$", block_text, re.DOTALL)
    if body_match:
        body = body_match.group(1)
    else:
        body = ""

    events = extract_events(body)
    actions = pair_action_events(events)

    rp_action_lines = []
    for message, pre, post in actions:
        rp_action_lines.append(f'        ["Chat", "{message}", {pre}, {post}]')

    rp_actions = ",\n".join(rp_action_lines)

    transformed = f"""{header} {{
    RPAction([
{rp_actions}
    ])
}}"""
    return transformed


def parse_function_blocks(input_text):
    lines = input_text.splitlines()
    blocks = []
    current_block = []
    in_block = False
    brace_count = 0
    header_regex = re.compile(r"^(?P<header>\w+\s*\([^)]*\))\s*(\{)?\s*$")

    i = 0
    n = len(lines)
    while i < n:
        line = lines[i]
        if not in_block:
            header_match = header_regex.match(line.strip())
            if header_match:
                in_block = True
                current_block = [line]
                if "{" in line:
                    brace_count = line.count("{") - line.count("}")
                else:
                    brace_count = 0
        else:
            current_block.append(line)
            brace_count += line.count("{") - line.count("}")
            if brace_count == 0 and "}" in line:
                block_str = "\n".join(current_block)
                blocks.append(block_str)
                in_block = False
                current_block = []
        i += 1
    return blocks


def transform_text(input_text):
    blocks = parse_function_blocks(input_text)
    transformed_blocks = []
    for block in blocks:
        transformed_block = transform_function_block(block)
        transformed_blocks.append(transformed_block)
    return "\n\n".join(transformed_blocks)


def main():
    result = transform_text(input_text)
    print("Result:\n")
    print(result)


if __name__ == "__main__":
    main()
