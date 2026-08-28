local M = {}

local lines = {
  "  neovim  ·  leader = espaço  ·  q / esc fecha isto  ·  <leader>? reabre",
  "",
  "  arquivos",
  "    <leader><leader>   achar arquivos          <leader>/    grep no projeto",
  "    <leader>b          buffers                 <leader>o    recentes",
  "    -  /  <leader>e    oil (pasta do arquivo)  <leader>w    salvar",
  "",
  "  codigo  (lsp)",
  "    gd                 ir para definicao       gD           declaracao",
  "    grr  /  <leader>sr usos no projeto         gri          implementacoes",
  "    <leader>ss         simbolos do arquivo     <leader>sS   simbolos do workspace",
  "    <leader>si         quem chama isto         <leader>so   o que isto chama",
  "    K                  documentacao            gra          code action",
  "    grn                rename                  [d  ]d       erro anterior/proximo",
  "    <leader>ld         diagnostico da linha    <leader>lD   todos os erros",
  "    <leader>F          formatar",
  "",
  "  rodar / testar  (go · js/ts · python, conforme o projeto)",
  "    <leader>rr         picker: scripts / go run / makefile / python",
  "    <leader>rt         testes do projeto       <leader>rf   testes deste arquivo",
  "",
  "  debug",
  "    <leader>db         breakpoint              <leader>dc   continue / start",
  "    <leader>do         step over               <leader>di   step into",
  "    <leader>dO         step out                <leader>dt   debug teste (ou arquivo js)",
  "    <leader>du         ui (stack + variaveis)",
  "",
  "  git",
  "    <leader>gS         status                  <leader>gc   commits",
  "    <leader>gB         branches                <leader>gs   stage hunk",
  "    <leader>gp         preview hunk            ]c  [c       hunk proximo/anterior",
  "",
  "  notas  (obsidian: ~/local/produtividade)",
  "    <leader>nn         nota nova               <leader>ns   buscar notas",
  "    <leader>nq         troca rapida            <leader>nt   nota de hoje",
  "    <leader>nb         backlinks               <leader>no   abrir no obsidian",
  "",
  "  terminal / extras",
  "    <leader>t          terminal split          <leader>T    terminal vertical",
  "    esc esc            sair do insert do terminal",
  "    sa  sd  sr         surround add/delete/replace",
  "    :PythonVenv        mostra o python do .venv",
  "    :Lazy  :Mason      plugins e language servers",
  "",
  "  dica: segura espaço um instante para ver os grupos do which-key.",
}

function M.show()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "cheatsheet"
  vim.bo[buf].modifiable = false
  vim.bo[buf].readonly = true
  vim.bo[buf].buflisted = false

  local width = 78
  local height = math.min(#lines + 2, math.max(12, vim.o.lines - 6))
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = " atalhos ",
    title_pos = "center",
  })
  vim.wo[win].cursorline = true
  vim.wo[win].winhighlight = "Normal:Normal,FloatBorder:FloatBorder"

  local close = function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end
  vim.keymap.set("n", "q", close, { buffer = buf, nowait = true, desc = "Close cheatsheet" })
  vim.keymap.set("n", "<Esc>", close, { buffer = buf, nowait = true, desc = "Close cheatsheet" })
end

return M
