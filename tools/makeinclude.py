import os, sys, time

instructions = ['INSADD', 'INSADC', 'INSCMP', 'INSSUB', 'INSSBC', 'INSSWAP', 'INSUMUL', 'INSSMUL', 'INSAND', 'INSOR', 'INSXOR', 'INSASL', 'INSLSL', 'INSASR', 'INSLSR', 'INSROL', 'INSRLC', 'INSROR', 'INSRRC', 'INSINC', 'INSDEC']
addresses = []

if os.path.exists('..\\output\\VIRTUAL16.lst'):
    with open('..\\output\\VIRTUAL16.lst', 'r') as f:
        lines = f.readlines()
else:
    input(".lst file not found, please run compile.sh file. Press enter to exit program")
    sys.exit(0)

for line in lines:
    try:
        if line.split()[0] in instructions:
            address = line.split()[1]
            address = '0x' + address
            addresses.append('.equ ' + line.split()[0] + ' ' + address)
    except:
        pass

with open('..\\src\\VIRTUAL16.inc', 'w') as f:
    for address in addresses:
        f.write(address + '\n')