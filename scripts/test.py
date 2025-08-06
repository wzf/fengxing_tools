def main(arguments):
    print("4 ==== 开始")
    for i in arguments:
        print(i)
    pass

if __name__ == "__main__":
    # 获取当前命令行传入的参数
    import sys
    arguments = sys.argv[1:]
    main(arguments)