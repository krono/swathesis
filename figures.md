## How to Create Nice Figures with Matplotlib for this Template ##

Here is a snippet as a starting point (it requires matplotlib and seaborn, e.g. `pip install matplotlib seaborn`), to configure matplotlib/seaborn figures so they:

- use the palatino font (which is the default font of the thesis template)
- fit the textwidth (5.14 in) without manually scaling
- have a small-ish but still readable font size (would not recommend to go with even smaller font)

This was tested with the PhD thesis template.

```
import matplotlib
import seaborn as sns
import matplotlib.pyplot as plt

FIGURE_WIDTH = 5.14  # inch, it matches the textwidth
FIGURE_HEIGHT = 5    # use anything you want

# choose one of the following or study https://seaborn.pydata.org/tutorial/aesthetics.html
# sns.set_theme(style="darkgrid", palette="Paired")
sns.set_theme(style="whitegrid", palette="Paired")

# this sets smaller but still readable font size and margins:
sns.set_context("paper")

matplotlib.rcParams["font.family"] = "palatino"
matplotlib.rcParams["mathtext.fontset"] = "cm"
# this sets the default figure size, but it could also be modified for individual figures:
matplotlib.rcParams["figure.figsize"] = (FIGURE_WIDTH, FIGURE_HEIGHT)

# TODO: create your figure with matplotlib and/or seaborn here

plt.savefig("figure.pdf", dpi=300, bbox_inches="tight", pad_inches=0)
# also save PNG, e.g. for quick preview:
# plt.savefig(f"figure.png", dpi=100, bbox_inches="tight", pad_inches=0)
```
