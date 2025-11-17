#! /usr/bin/python3
import sys
import re
# 前两个(或多个)参数是 bool 验证阶段输出的 txt 文件，最后两个参数
# 分别表示需要插入标记的 .shadow.bpl 文件以及输出文件。如果只提供
# 一个 bool 结果和一个 .bpl 文件(旧调用方式)，则默认在原文件上原地
# 写回，并且只使用提供的那一个 bool 结果。
argv = sys.argv[1:]

if len(argv) < 2:
    raise SystemExit("Usage: transBoolToShadow.py <bool.txt> [<bool2.txt> ...] <shadow.bpl> [<output.bpl>]")

if len(argv) == 2:
    bool_records = [argv[0]]
    arg3 = argv[1]
    arg4 = argv[1]
else:
    bool_records = argv[:-2]
    arg3 = argv[-2]
    arg4 = argv[-1]


# try:
#     lines = file_object.readlines()
#     for line in lines:
#         print (line)
# finally:
#     file_object.close()

# 将两次分析结果不成立的地方读取出来
def processOutPut():
    poss = []
    errs = r'.*Error:.*might not'
    posr = r'bpl\(.*,'

    for record in bool_records:
        file_object = open(record, 'r')
        try:
            lines = file_object.readlines()
        finally:
            file_object.close()

        for line in lines:
            if re.match(errs, line):
                tar = re.search(posr, line).group()
                pos = re.sub(r'\D',"",tar)
                poss.append(int(pos))

    poss = set(poss)

    return poss


def doMark(poss):
    ls = []
    file_object = open(arg3, 'r')
    try:
        lines = file_object.readlines()
        # print(type(lines)) 
    finally:
        file_object.close()
    # for idx,line in enumerate(lines):
    #     if lines[idx][:-1] == '\n':
    #         lines[idx] = lines[idx][:-1]

    # for line in lines:
    #     print(line)

    mark = "  assume {:VFCTMarked} true;\n"
    
    with open(arg4, 'w') as f:
        for idx, line in enumerate(lines):
            if (idx+1) in poss:
                f.write(mark)
            f.write(line)

    # for idx,line in enumerate(lines):
    #     if re.match(r6, line) or re.match(rassert, line):
    #         if idx not in poss:
    #             lines.insert(idx, mark)  




poss = processOutPut()
print(poss)
doMark(poss)















# 原本打算只用正则表达式完成替换时的写法。里面有一些识别用的正则表达式
'''
def doMark(poss):
    file_object = open(arg2, 'r')
    try:
        lines = file_object.readlines()
        # print(type(lines)) 
    finally:
        file_object.close()
    # for idx,line in enumerate(lines):
    #     if lines[idx][:-1] == '\n':
    #         lines[idx] = lines[idx][:-1]

    # for line in lines:
    #     print(line)

    rassert = r'.*assert.*'
    r1 = r'.*assert \$shadow_ok;'
    r2 = r'.*assert \{:shadow_invariant\} \$shadow_ok;'
    r3 = r'.*assert \{:shadow_invariant\} \('
    r4 = r'.*assert \{:likely_shadow_invariant\} \('
    r5 = r'.*assert \{:unlikely_shadow_invariant \('
    r6 = r'.*\$shadow_ok := \(\$shadow_ok.*'

    r7 = r'.*\.shadow.*'
    for idx,line in enumerate(lines):
        if re.match(r6, line) or re.match(rassert, line):
            if idx not in poss:
                if re.match(r1, line):
                    line = "  $shadow_ok := true;\n"
                if re.match(r2, line):
                    line = "  $shadow_ok := true;\n"
                if re.match(r3, line):
                    line = line[0:2] + line[30:]
                    line = line[:-3] +";\n"
                    line = re.sub(r'==',":=",line)
                if re.match(r4, line):
                    line = line[0:2] + line[37:]
                    line = line[:-3] +";\n"
                    line = re.sub(r'==',":=",line)
                if re.match(r5, line):
                    line = "// " + line
                    # line = re.sub(r'==',":=",line)
                    # line = line[0:2] + line[38:]
                    # line = line[:-2] +";"
                #特殊处理，因为表达式不能赋值
                #shadow_ok后面有两个括号，所以要多去掉一个。
                if re.match(r6, line):
                    tmp = line[0:2] + line[32:]
                    tmp = tmp[:-4] +";\n"
                    if(re.match(r7, tmp)):
                        line = tmp
                        line = re.sub(r'==',":=",line)
                # print(line)
                lines[idx] = line

    with open(arg2, 'w') as f:
        for line in lines:
            # print(line + "\n")
            f.write(line)
'''