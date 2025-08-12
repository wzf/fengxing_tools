
import os
import sys

def rename_files(params):
    """
    批量重命名目录中的文件
    
    参数:
        directory: 目标目录路径
        prefix: 新文件名前缀
        start_num: 起始编号(默认为1)
    """
    directory = params['directory']
    prefix = params['prefix']
    start_num = params['start_num']

    try:
        # 获取目录下所有文件
        files = [f for f in os.listdir(directory) if os.path.isfile(os.path.join(directory, f))]
        
        # 过滤掉隐藏文件
        files = [f for f in files if not f.startswith('.')]
        
        # 按文件名排序
        files.sort()
        
        # 计数器
        count = int(start_num)
        
        for filename in files:
            # 获取文件扩展名
            ext = os.path.splitext(filename)[1]
            
            # 构建新文件名
            new_name = f"{prefix}{count}{ext}"
            
            # 原文件完整路径
            old_path = os.path.join(directory, filename)

            # 新文件完整路径
            new_path = os.path.join(directory, new_name)
            
            # 重命名文件
            os.rename(old_path, new_path)
            print(f"重命名: {filename} -> {new_name}")
            
            count += 1
            
        print(f"\n完成! 共重命名了 {len(files)} 个文件")
        
    except Exception as e:
        print(f"发生错误: {e}")


def parse_args_to_dict():
    """
    将命令行参数解析为字典
    格式要求: -key1 value1 -key2 value2 ...
    返回: 包含参数键值对的字典
    """
    print(sys.argv)
    args = sys.argv[1:]  # 跳过脚本名
    result = {}
    i = 0
    while i < len(args):
        if args[i].startswith('-'):
            key = args[i][1:]  # 去掉前导的'-'
            if i + 1 < len(args) and not args[i+1].startswith('-'):
                result[key] = args[i+1]
                i += 2
            else:
                result[key] = True  # 没有值的参数设为True
                i += 1
        else:
            i += 1
    return result


if __name__ == "__main__":
    # 参数转字典
    args_dict = parse_args_to_dict()
    print(args_dict)
    
    # 调用重命名函数
    rename_files(args_dict)
