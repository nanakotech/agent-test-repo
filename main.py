def greet(name):
    return "Hello Alice" if name == "Alice" else f"Hello, {name}!"

if __name__ == "__main__":
    import sys
    if len(sys.argv) > 1:
        print(greet(sys.argv[1]))
    else:
        print("Please provide a name as an argument.")
