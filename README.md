SETUP

- install LOVE2D
- install [lua language server by sumneko](https://marketplace.visualstudio.com/items?itemName=sumneko.lua) and [love2d support by pixelbyte studios](https://marketplace.visualstudio.com/items?itemName=pixelbyte-studios.pixelbyte-love2d)
- disable certain language server warnings by hovering over them, quick fix (ctrl+.) and selecting the according option, or adding this to the .vscode settings.json in the repo

```
  {
      "Lua.diagnostics.disable": [
          "lowercase-global"
      ],
      "Lua.diagnostics.globals": [
          "love"
      ]
  }
```
- if the love2d support extension has the correct love2d path, set RunOnSave to true, save, then run.
