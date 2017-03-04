def prettify(results):
    pretty = []

    col_widths = [0 for i in range(len(results[0]))]
    for row in results:
        for i in range(len(row)):
            col_widths[i] = max(col_widths[i], len(row[i]))

    for row in results:
        pretty.append("\t".join(row[i].ljust(col_widths[i] + 1) for i in range(len(row))))

    return pretty