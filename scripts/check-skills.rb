#!/usr/bin/env ruby
# frozen_string_literal: true
#
# check-skills.rb - Everything `claude plugin validate` does not check.
#
# The official validator owns manifest schema. It never reads SKILL.md, so a
# skill with broken or missing frontmatter passes it and is silently dead.
#
# Claude Code's own frontmatter parser is lenient too, which hides a real bug:
#   description: Does a thing. Keywords: a, b, c
# loads fine in Claude Code but is invalid YAML, because the second colon
# opens a nested mapping. `npx skills` SKIPS such a skill without failing, so
# it cannot be installed on its own and nothing tells you.
#
# Checks:
#   - every skills/**/SKILL.md parses as YAML and has name + description
#   - name matches its directory
#   - no two skills share a name (they collide inside one plugin)
#   - every agents/*.md parses and has name + description
#   - every path in plugin.json exists on disk
#   - every shippable skill on disk is listed in plugin.json
#
# Usage: ruby scripts/check-skills.rb

require 'yaml'
require 'json'

Dir.chdir(File.expand_path('..', __dir__))

RED = "\e[0;31m"
GREEN = "\e[0;32m"
NC = "\e[0m"

problems = []
def_err = ->(list, path, why) { list << [path, why] }

# --- frontmatter -----------------------------------------------------------

def frontmatter(path)
  text = File.read(path)
  m = text.match(/\A---\n(.*?)\n---\n/m)
  return [nil, 'no frontmatter block'] unless m

  begin
    data = YAML.safe_load(m[1])
  rescue Psych::SyntaxError => e
    return [nil, "invalid YAML: #{e.message.split("\n").first}"]
  end
  return [nil, 'frontmatter is not a mapping'] unless data.is_a?(Hash)

  [data, nil]
end

skill_files = Dir.glob('skills/**/SKILL.md').sort
seen = {}

skill_files.each do |path|
  data, err = frontmatter(path)
  if err
    def_err.call(problems, path, err)
    next
  end

  %w[name description].each do |key|
    def_err.call(problems, path, "missing '#{key}'") if data[key].to_s.strip.empty?
  end

  name = data['name'].to_s
  expected = File.basename(File.dirname(path))
  if !name.empty? && name != expected
    def_err.call(problems, path, "name '#{name}' does not match directory '#{expected}'")
  end

  if seen.key?(name) && !name.empty?
    def_err.call(problems, path, "duplicate skill name '#{name}', also in #{seen[name]}")
  end
  seen[name] = path unless name.empty?
end
puts "#{GREEN}✓#{NC} #{skill_files.size} skills parsed"

agent_files = Dir.glob('agents/*.md').sort
agent_files.each do |path|
  data, err = frontmatter(path)
  if err
    def_err.call(problems, path, err)
    next
  end
  %w[name description].each do |key|
    def_err.call(problems, path, "missing '#{key}'") if data[key].to_s.strip.empty?
  end
end
puts "#{GREEN}✓#{NC} #{agent_files.size} agents parsed"

# --- manifest --------------------------------------------------------------

manifest = JSON.parse(File.read('.claude-plugin/plugin.json'))
listed = (manifest['skills'] || []) + (manifest['agents'] || []) + (manifest['commands'] || [])

listed.each do |entry|
  def_err.call(problems, '.claude-plugin/plugin.json', "lists #{entry}, which does not exist") unless File.exist?(entry)
end
puts "#{GREEN}✓#{NC} #{listed.size} manifest paths exist"

# A skill on disk but absent from the manifest ships nothing. in-progress/ is
# excluded on purpose: that is how unfinished work stays out of a release.
shippable = skill_files.reject { |p| p.include?('/in-progress/') }
skill_dirs = manifest['skills'] || []
shippable.each do |path|
  dir = "./#{File.dirname(path)}"
  next if skill_dirs.include?(dir)

  def_err.call(problems, dir, 'exists but is not listed in plugin.json, so it will not ship')
end
puts "#{GREEN}✓#{NC} #{shippable.size} skills are listed to ship"

# --- result ----------------------------------------------------------------

puts
if problems.empty?
  puts "#{GREEN}✓ All checks passed#{NC}"
  exit 0
end

problems.each { |path, why| warn "#{RED}ERROR:#{NC} #{path}: #{why}" }
warn "#{RED}✗ #{problems.size} problem(s)#{NC}"
exit 1
