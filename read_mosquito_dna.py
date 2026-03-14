
import sys

file_path = "/Users/ek/Desktop/mosquito-dna/Lucati_et_al_2022_Multiple_invasions,_Wolbachia_and_human-aided_transport_drive_the_genetic.md"

try:
    with open(file_path, 'r', encoding='utf-8') as f:
        print(f.read())
except Exception as e:
    print(f"Error: {e}")
    sys.exit(1)
