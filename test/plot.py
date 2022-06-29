import matplotlib.pyplot as plt
import matplotlib.ticker as ticker

import numpy as np
import csv
import re
from pathlib import Path



def main():
    path = Path("data").joinpath("results.csv")

    ts = dict()

    with open(path, "r") as file:
        for line in csv.DictReader(file):
            for (key, val) in line.items():
                if key not in ts:
                    ts[key] = [float(val)]
                else:
                    ts[key].append(float(val))
        
        ts = {key: np.array(arr) for (key, arr) in ts.items()}

    t = np.array(list(range(len(ts["p"]))))

    fig, ax = plt.subplots(4, 1, figsize=(64, 32))

    w = 2.0

    ax[0].scatter(t, ts["p"], s=w)

    codes = [32, 33]

    n = len(codes)
    wn = w / max(1, (n - 1))

    for i in range(n):
        cd = codes[i]
        ti = t - (w / 2.0) + i * wn
        ax[1].bar(ti, ts[f"operation_{cd}"]   , width=wn)
        ax[2].bar(ti, ts[f"charge_{cd}"]      , width=wn)
        ax[3].bar(ti, ts[f"charge_delta_{cd}"], width=wn)

    ax[0].set_title(r"Price ($ / Wh)"     , fontsize=48)
    ax[1].set_title(r"Operation ($)"      , fontsize=48)
    ax[2].set_title(r"Charge (Wh)"        , fontsize=48)
    ax[3].set_title(r"Charge Transfer (W)", fontsize=48)

    plt.savefig("plot.png")

if __name__ == '__main__':
    main() # Here we go!