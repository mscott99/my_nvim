return {
  {
    '3rd/image.nvim',
    build = false, -- so that it doesn't build the rock https://github.com/3rd/image.nvim/issues/91#issuecomment-2453430239
    opts = {
      processor = 'magick_cli',
      backend = 'kitty', -- Kitty will provide the best experience, but you need a compatible terminal
      -- integrations = {}, -- do whatever you want with image.nvim's integrations
      scale_factor = 2.0,
      max_width = 100, -- tweak to preference
      max_height = 50, -- ^
      max_height_window_percentage = math.huge, -- this is necessary for a good experience
      max_width_window_percentage = math.huge,
      window_overlap_clear_enabled = true,
      window_overlap_clear_ft_ignore = { 'cmp_menu', 'cmp_docs', '' },
    },
  },
  {
    'benlubas/molten-nvim',
    lazy=false,
    version = '^1.0.0', -- use version <2.0.0 to avoid breaking changes
    dependencies = { '3rd/image.nvim' },
    build = ':UpdateRemotePlugins',
    init = function()
      -- these are examples, not defaults. Please see the readme
      vim.g.molten_image_provider = 'image.nvim'
      vim.g.molten_output_win_max_height = 500
    end,
  },
}
