def print_results(results):
    col_widths = [0 for i in range(len(results[0]))]
    for row in results:
        for i in range(len(row)):
            col_widths[i] = max(col_widths[i], len(row[i]))

    for row in results:
        print("".join(row[i].ljust(col_widths[i] + 2) for i in range(len(row))))
