
import os
import sys
from PIL import Image

def main(params):
    """
    调整图片大小、质量压缩
    
    参数:
        input_path: 图片路径
        width: 要调整后的宽度(px)
        height: 要调整后的高度(px)
        quality: 压缩质量，从0-1
        output_suffix: 文件重命名后的后缀名
    """
    input_path = params['input_path']
    width = int(params['width'])
    height = int(params['height'])
    quality = float(params['quality'])
    output_suffix = params['output_suffix']

    try:
        # 打开原始图片
        img = Image.open(input_path)
        
        # 调整尺寸
        resized_img = img.resize((width, height), Image.LANCZOS)
        
        # 构建输出路径
        base, ext = os.path.splitext(input_path)
        output_path = f"{base}{output_suffix}{ext}"
        
        # 保存图片（根据格式处理质量参数）
        if ext.lower() in ['.jpg', '.jpeg']:
            resized_img.save(output_path, quality=int(quality*100))
        elif ext.lower() == '.png':
            resized_img.save(output_path, optimize=True, quality=int(quality*100))
        else:
            resized_img.save(output_path)
            
        print(f"图片已处理并保存为: {output_path}")
        
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
    main(args_dict)
