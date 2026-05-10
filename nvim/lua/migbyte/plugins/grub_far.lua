return {
  'MagicDuck/grug-far.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' }, -- optional
  config = function()
    local grug_far = require('grug-far')

    -- Configure grug-far
    grug_far.setup({
      -- debounce milliseconds for search as you type
      debounceMs = 500,
      -- minimum characters before auto-search
      minSearchChars = 2,
      -- max number of parallel ripgrep instances
      maxResultsLines = 2000,
      -- can be "ripgrep" or "astgrep"
      engine = 'ripgrep',
      -- sets transparency of the floating windows (if used)
      windowCreationCommand = 'vsplit',
    })

    --====================================================================
    --                        Key Mappings
    --====================================================================
    local keymap = vim.keymap

    -- Open grug-far with <leader>fr (Find/Replace)
    keymap.set('n', '<leader>fr', function()
      grug_far.open()
    end, { desc = 'GrugFar: Open Find and Replace' })

    -- Open grug-far and pre-fill with word under cursor
    keymap.set('n', '<leader>fw', function()
      grug_far.open({ prefills = { search = vim.fn.expand("<cword>") } })
    end, { desc = 'GrugFar: Search current word' })

    -- Open grug-far limited to current file
    keymap.set('n', '<leader>ff', function()
      grug_far.open({ prefills = { paths = vim.fn.expand("%") } })
    end, { desc = 'GrugFar: Search in current file' })

    -- Search within visual selection range
    keymap.set('v', '<leader>fr', function()
      -- This triggers grug-far for the selected text
      grug_far.with_visual_selection({})
    end, { desc = 'GrugFar: Search selection' })

    -- Toggle a specialized instance (e.g., for a 'search and replace' project)
    keymap.set('n', '<leader>ft', function()
      grug_far.toggle_instance({ instanceName = "far", staticTitle = "Global Search" })
    end, { desc = 'GrugFar: Toggle persistent instance' })

    --====================================================================
    --                  Buffer-Local Customizations
    --====================================================================
    -- These only apply when you are inside the grug-far buffer
    vim.api.nvim_create_autocmd('FileType', {
      group = vim.api.nvim_create_augroup('grug-far-custom-binds', { clear = true }),
      pattern = { 'grug-far' },
      callback = function()
        -- Example: Jump back to inputs easily with <C-k>
        keymap.set('n', '<C-k>', function()
          grug_far.get_instance(0):goto_first_input()
        end, { buffer = true, desc = 'GrugFar: Jump to inputs' })

        -- Example: Force a replace and close the buffer immediately with <C-Enter>
        keymap.set('n', '<C-cr>', function()
          grug_far.get_instance(0):replace()
          grug_far.get_instance(0):close()
        end, { buffer = true, desc = 'GrugFar: Replace and Close' })
      end,
    })
  end,
}
