-- lua/migbyte/laravel_make.lua  ----------------------------------------------
-- Interactive creator for Models, Controllers, Providers, Factories, Seeders,
-- Migrations, and Blade views.

local M = {}

--------------------------------------------------------------------- utilities
local function project_root()
  local markers, dir = { "artisan", "composer.json", ".git" }, vim.fn.expand("%:p:h")
  while dir ~= "/" do
    for _, m in ipairs(markers) do
      if vim.fn.filereadable(dir .. "/" .. m) == 1
          or vim.fn.isdirectory(dir .. "/" .. m) == 1
      then
        return dir
      end
    end
    dir = vim.fn.fnamemodify(dir, ":h")
  end
  return vim.loop.cwd()
end

local function studly(s)
  return (s:gsub("(%a)([%w_]*)", function(a, b)
    return a:upper() .. b:lower():gsub("_(%w)", function(c) return c:upper() end)
  end))
end

local function ensure_dir(p) if vim.fn.isdirectory(p) == 0 then vim.fn.mkdir(p, "p") end end

local function write_stub(path, lines)
  if vim.fn.filereadable(path) == 0 then
    ensure_dir(vim.fn.fnamemodify(path, ":h"))
    local fd = assert(io.open(path, "w"))
    for _, l in ipairs(lines) do fd:write(l .. "\n") end
    fd:close()
  end
end

------------------------------------------------------------------ generic PHP
local function new_php(rel_dir, default_name, stub_fn)
  vim.ui.input({ prompt = "Class name: ", default = default_name }, function(input)
    if not input or input == "" then return end
    local cls  = studly(input)
    local root = project_root()
    local dir  = root .. "/" .. rel_dir
    local path = dir .. "/" .. cls .. ".php"
    write_stub(path, stub_fn(cls))
    vim.cmd.edit(path)
  end)
end

---------------------------------------------------------------- artefact APIs
function M.make_model()
  new_php("app/Models", "", function(cls)
    return {
      "<?php",
      "",
      "namespace App\\Models;",
      "",
      "use Illuminate\\Database\\Eloquent\\Factories\\HasFactory;",
      "use Illuminate\\Database\\Eloquent\\Model;",
      "",
      "class " .. cls .. " extends Model",
      "{",
      "    use HasFactory;",
      "    protected $guarded = [];",
      "}",
    }
  end)
end

function M.make_controller()
  new_php("app/Http/Controllers", "UserController", function(cls)
    local c = cls:match("Controller$") and cls or (cls .. "Controller")
    return {
      "<?php",
      "",
      "namespace App\\Http\\Controllers;",
      "",
      "use Illuminate\\Http\\Request;",
      "",
      "class " .. c .. " extends Controller",
      "{",
      "    //",
      "}",
    }
  end)
end

function M.make_provider()
  new_php("app/Http/Providers", "AppServiceProvider", function(cls)
    local p = cls:match("Provider$") and cls or (cls .. "Provider")
    return {
      "<?php",
      "",
      "namespace App\\Http\\Providers;",
      "",
      "use Illuminate\\Support\\ServiceProvider;",
      "",
      "class " .. p .. " extends ServiceProvider",
      "{",
      "    public function register(): void {}",
      "    public function boot(): void {}",
      "}",
    }
  end)
end

function M.make_factory()
  new_php("database/factories", "UserFactory", function(cls)
    local f = cls:match("Factory$") and cls or (cls .. "Factory")
    return {
      "<?php",
      "",
      "namespace Database\\Factories;",
      "",
      "use Illuminate\\Database\\Eloquent\\Factories\\Factory;",
      "",
      "class " .. f .. " extends Factory",
      "{",
      "    public function definition(): array",
      "    {",
      "        return [",
      "            //",
      "        ];",
      "    }",
      "}",
    }
  end)
end

function M.make_seeder()
  new_php("database/seeders", "UserSeeder", function(cls)
    local s = cls:match("Seeder$") and cls or (cls .. "Seeder")
    return {
      "<?php",
      "",
      "namespace Database\\Seeders;",
      "",
      "use Illuminate\\Database\\Seeder;",
      "",
      "class " .. s .. " extends Seeder",
      "{",
      "    public function run(): void",
      "    {",
      "        //",
      "    }",
      "}",
    }
  end)
end

function M.make_migration()
  vim.ui.input({ prompt = "Migration name (snake_case): " }, function(name)
    if not name or name == "" then return end
    local root, dir = project_root(), project_root() .. "/database/migrations"
    ensure_dir(dir)
    local stamp = os.date("%Y_%m_%d_%H%M%S")
    local file  = dir .. "/" .. stamp .. "_" .. name .. ".php"
    write_stub(file, {
      "<?php",
      "",
      "use Illuminate\\Database\\Migrations\\Migration;",
      "use Illuminate\\Database\\Schema\\Blueprint;",
      "use Illuminate\\Support\\Facades\\Schema;",
      "",
      "return new class extends Migration",
      "{",
      "    public function up(): void",
      "    {",
      "        Schema::create('" .. name .. "', function (Blueprint $table) {",
      "            $table->id();",
      "            $table->timestamps();",
      "        });",
      "    }",
      "",
      "    public function down(): void",
      "    {",
      "        Schema::dropIfExists('" .. name .. "');",
      "    }",
      "};",
    })
    vim.cmd.edit(file)
  end)
end

function M.make_view()
  vim.ui.input({ prompt = "View path (e.g. admin/dashboard): " }, function(rel)
    if not rel or rel == "" then return end
    local root = project_root()
    local path = root .. "/resources/views/" .. rel .. ".blade.php"
    ensure_dir(vim.fn.fnamemodify(path, ":h"))
    write_stub(path, { "<!-- " .. rel .. ".blade.php -->" })
    vim.cmd.edit(path)
  end)
end

return M
