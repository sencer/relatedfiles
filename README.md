# Related Files Plugin for Neovim

A custom plugin to quickly find and switch between related files based on naming conventions. It also integrates with Google-specific tools like `BUILD` files.

## Features

-   **Conventions**:
    -   C++: `.cc` <-> `.h` <-> `_test.cc` <-> `_main.cc`
    -   Python: `.py` <-> `_test.py` <-> `_main.py`
-   **`BUILD` File Integration**:
    -   Finds the corresponding `BUILD` file and jumps to the line where the current file is listed.
-   **Native Menus**: Uses `vim.ui.select` for picking files when multiple options are available.

## Keybindings

The plugin sets up default keybindings unless overridden:

-   `<Leader>r`: Switch directly if only 1 match (Navigation mode).
-   `<Leader>R`: Always show menu (Creation mode).
-   `<Leader>rt`: Go directly to existing test file.
-   `<Leader>rT`: Create and go directly to test file (no menu).
-   `<Leader>rr`: Go directly to existing source file.
-   `<Leader>rR`: Create and go directly to source file (no menu).
-   `<Leader>rm`: Go directly to existing main file.
-   `<Leader>rM`: Create and go directly to main file (no menu).
-   `<Leader>rb`: Go directly to existing `BUILD` file.
-   `<Leader>rB`: Create and go directly to `BUILD` file (no menu).

## Configuration

To disable default mappings, set this in your `init.vim`:
```vim
let g:related_no_default_mappings = 1
```
Then you can define your own mappings to the provided `<Plug>` targets:
- `<Plug>RelatedFind`
- `<Plug>RelatedCreate`
- `<Plug>RelatedFindTest`
- `<Plug>RelatedCreateTest`
- `<Plug>RelatedFindSource`
- `<Plug>RelatedCreateSource`
- `<Plug>RelatedFindMain`
- `<Plug>RelatedCreateMain`
- `<Plug>RelatedFindBuild`
- `<Plug>RelatedCreateBuild`
```
