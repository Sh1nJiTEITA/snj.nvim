local is_file_exists = function(path)
   return vim.fn.filereadable(path)
end

TexLauncherInstance = {
   current_path = "",

   update_path = function(this)
      local new_path = vim.fn.input("Enter path to working file: ")
      vim.cmd("redraw")
      if is_file_exists(new_path) then
         this.current_path = new_path
         print("Path updated: " .. new_path)
      else
         vim.notify("Error: input path does not exists!", vim.log.levels.ERROR)
      end
   end,

   show_current_path = function(this)
      print(this.current_path)
   end,
}

local add_command = function(name, this, method)
   vim.api.nvim_create_user_command(name, function()
      this[method](this)
   end, { nargs = 0 })
end

add_command("TLSetFile", TexLauncherInstance, "update_path")
add_command("TLShowFile", TexLauncherInstance, "show_current_path")
