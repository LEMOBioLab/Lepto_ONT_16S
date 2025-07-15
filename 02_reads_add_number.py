#!/usr/bin/env python3
import sys

def add_sequential_number_to_headers(input_fasta, output_fasta):
    counter = 1
    with open(input_fasta, 'r') as f_in, open(output_fasta, 'w') as f_out:
        for line in f_in:
            if line.startswith('>'):
                # Se añade el número secuencial al final del header
                header = line.strip() + '_'  + str(counter) + '\n'
                f_out.write(header)
                counter += 1
            else:
                f_out.write(line)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("python3 reads_add_number.py <input.fasta> <output.fasta>")
        sys.exit(1)

    add_sequential_number_to_headers(sys.argv[1], sys.argv[2])
