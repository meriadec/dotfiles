require("nvim-treesitter.configs").setup({
    indent = { enable = true },
    ensure_installed = {
        "javascript",
        "typescript",
        "tsx",
        "lua",
        "json",
        "jsonc",
        "yaml",
    },
    highlight = { enable = true },
    -- plugins
    -- autopairs = { enable = true },
    -- context_commentstring = {
    --     enable = true,
    -- },
    -- textsubjects = {
    --     enable = true,
    --     keymaps = {
    --         ["."] = "textsubjects-smart",
    --         [";"] = "textsubjects-container-outer",
    --     },
    -- },
    -- matchup = {
    --     enable = true,
    -- },
})
