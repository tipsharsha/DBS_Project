#read file
count = 1
with open('error.txt', 'r') as f:
    # read lines
    for line in f:
        print(line)
        if line == 'Procedure created.':
            print('yes')
            count+=1
        elif line == 'Warning: Procedure created with compilation errors.':
            break
print(count)