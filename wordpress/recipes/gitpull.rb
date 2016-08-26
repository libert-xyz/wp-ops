
execute node['wordpress']['wp_path'] do
  command 'git pull origin master'
end
