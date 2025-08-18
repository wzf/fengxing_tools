
import os
import sys
from PIL import Image
from pyzbar import pyzbar

def main(params):
    """
    批量重命名目录中的文件
    
    参数:
        file: 二维码图片路径
    """
    file = params['file']

    try:
        # 读取图片文件
        image = Image.open(file)
        if image is None:
            raise ValueError("无法读取图片文件")

        # 转换为灰度图提高识别率
        # gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        
        # 使用pyzbar解码
        decoded_objects = pyzbar.decode(image)
        if not decoded_objects:
            raise ValueError("未检测到二维码")

        # 返回第一个二维码内容
        content = decoded_objects[0].data.decode('utf-8')
            
        print(f"\n二维码识别完成：{content}")
        
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
