#!/usr/bin/env ruby

# Content Migration Script for Claude Code Documentation
# Converts .md files from .claude/human-handbook/docs/ to Jekyll pages

require 'fileutils'
require 'yaml'

class ContentMigrator
  def initialize
    @source_dir = File.expand_path('../.claude/human-handbook/docs', __dir__)
    @target_dir = File.expand_path('../docs', __dir__)
    @pages_dir = File.join(@target_dir, 'pages')

    # Categories mapping
    @category_mapping = {
      'commands-guide.md' => 'commands',
      'agents-guide.md' => 'agents',
      'ai-first-workflow.md' => 'workflows',
      'ai-first-best-practices.md' => 'best-practices',
      'quickstart.md' => 'best-practices'
    }

    # URL mapping for Jekyll
    @url_mapping = {
      'commands-guide.md' => '/commands/',
      'agents-guide.md' => '/agents/',
      'ai-first-workflow.md' => '/workflows/',
      'ai-first-best-practices.md' => '/best-practices/',
      'quickstart.md' => '/quickstart/'
    }

    puts "Content Migrator initialized"
    puts "Source: #{@source_dir}"
    puts "Target: #{@target_dir}"
  end

  def migrate_all
    unless Dir.exist?(@source_dir)
      puts "ERROR: Source directory does not exist: #{@source_dir}"
      return false
    end

    # Create target directories
    create_target_directories

    # Get all markdown files
    source_files = Dir.glob(File.join(@source_dir, '*.md'))

    if source_files.empty?
      puts "No markdown files found in source directory"
      return false
    end

    puts "\nFound #{source_files.length} files to migrate:"
    source_files.each { |f| puts "  - #{File.basename(f)}" }

    # Migrate each file
    success_count = 0
    source_files.each do |source_file|
      if migrate_file(source_file)
        success_count += 1
      end
    end

    puts "\nMigration completed: #{success_count}/#{source_files.length} files"

    # Create category index pages
    create_category_indexes

    true
  end

  private

  def create_target_directories
    # Create pages directory structure
    categories = @category_mapping.values.uniq
    categories.each do |category|
      category_dir = File.join(@pages_dir, category)
      FileUtils.mkdir_p(category_dir)
      puts "Created directory: #{category_dir}"
    end
  end

  def migrate_file(source_file)
    filename = File.basename(source_file)
    puts "\nProcessing: #{filename}"

    begin
      # Read source content
      content = File.read(source_file)

      # Extract or generate front matter
      front_matter, body = extract_front_matter(content, filename)

      # Process content
      processed_body = process_content(body, filename)

      # Generate target file
      target_file = generate_target_path(filename)

      # Write migrated content
      write_migrated_file(target_file, front_matter, processed_body)

      puts "  ✓ Migrated to: #{target_file}"
      true

    rescue => e
      puts "  ✗ Error migrating #{filename}: #{e.message}"
      false
    end
  end

  def extract_front_matter(content, filename)
    # Check if file already has front matter
    if content.start_with?('---')
      parts = content.split('---', 3)
      if parts.length >= 3
        existing_front_matter = YAML.safe_load(parts[1]) rescue {}
        body = parts[2].strip
      else
        existing_front_matter = {}
        body = content
      end
    else
      existing_front_matter = {}
      body = content
    end

    # Generate front matter
    front_matter = generate_front_matter(existing_front_matter, body, filename)

    [front_matter, body]
  end

  def generate_front_matter(existing, body, filename)
    # Extract title from content
    title = extract_title(body) || existing['title'] || filename.gsub('.md', '').split('-').map(&:capitalize).join(' ')

    # Generate front matter
    {
      'layout' => 'docs',
      'title' => title,
      'category' => @category_mapping[filename] || 'general',
      'permalink' => @url_mapping[filename] || "/#{filename.gsub('.md', '')}/",
      'description' => existing['description'] || extract_description(body),
      'tags' => existing['tags'] || generate_tags(body, filename),
      'toc' => true,
      'search' => true,
      'last_modified_at' => Time.now.strftime('%Y-%m-%d')
    }.merge(existing)
  end

  def extract_title(content)
    # Look for first H1
    if match = content.match(/^#\s+(.+)$/m)
      return match[1].strip
    end

    # Look for title in first few lines
    lines = content.split("\n").first(5)
    lines.each do |line|
      clean_line = line.strip
      if !clean_line.empty? && !clean_line.start_with?('#') && clean_line.length > 5
        return clean_line if clean_line.length < 100
      end
    end

    nil
  end

  def extract_description(content)
    # Get first paragraph that's not a heading
    lines = content.split("\n")
    description_lines = []

    lines.each do |line|
      clean_line = line.strip

      # Skip empty lines and headings
      next if clean_line.empty? || clean_line.start_with?('#')

      # Skip markdown metadata
      next if clean_line.start_with?('---') || clean_line.start_with?('<!--')

      # Add line to description
      description_lines << clean_line

      # Stop after we have enough content
      break if description_lines.join(' ').length > 100
    end

    description = description_lines.join(' ').strip
    description.empty? ? nil : description[0..200] + (description.length > 200 ? '...' : '')
  end

  def generate_tags(content, filename)
    tags = []

    # Base tags from filename
    case filename
    when 'commands-guide.md'
      tags += ['comandos', 'CLI', 'productividad']
    when 'agents-guide.md'
      tags += ['agentes', 'especialistas', 'AI']
    when 'ai-first-workflow.md'
      tags += ['workflow', 'metodología', 'AI-first']
    when 'ai-first-best-practices.md'
      tags += ['mejores-prácticas', 'patrones', 'técnicas']
    when 'quickstart.md'
      tags += ['inicio', 'configuración', 'guía']
    end

    # Extract technical terms from content
    technical_terms = [
      'implement', 'review', 'understand', 'claude', 'code',
      'desarrollador', 'programación', 'desarrollo', 'software'
    ]

    content_lower = content.downcase
    technical_terms.each do |term|
      tags << term if content_lower.include?(term) && !tags.include?(term)
    end

    tags.first(5) # Limit to 5 tags
  end

  def process_content(content, filename)
    # Remove existing front matter if present
    if content.start_with?('---')
      parts = content.split('---', 3)
      content = parts.length >= 3 ? parts[2].strip : content
    end

    # Process internal links
    content = process_internal_links(content)

    # Process code blocks
    content = process_code_blocks(content)

    # Add edit link at the bottom
    content += "\n\n---\n\n"
    content += "_📝 [Editar esta página en GitHub](#{github_edit_url(filename)})_\n"

    content
  end

  def process_internal_links(content)
    # Convert relative links to absolute Jekyll links
    content.gsub(/\]\((?!http)([^)]+)\.md\)/) do |match|
      link_file = "#{$1}.md"
      if @url_mapping[link_file]
        "](#{@url_mapping[link_file]})"
      else
        match # Keep original if no mapping found
      end
    end
  end

  def process_code_blocks(content)
    # Ensure code blocks have proper language specification
    content.gsub(/```(\w*)/) do |match|
      lang = $1
      if lang.empty?
        '```bash' # Default to bash for empty code blocks
      else
        match
      end
    end
  end

  def github_edit_url(filename)
    base_url = "https://github.com/trivance-ai/trivance-ai-orchestrator"
    "#{base_url}/edit/main/.claude/human-handbook/docs/#{filename}"
  end

  def generate_target_path(filename)
    category = @category_mapping[filename] || 'general'
    page_name = filename.gsub('.md', '')

    # Create index.md for main category pages
    if ['commands-guide', 'agents-guide', 'ai-first-workflow', 'ai-first-best-practices'].include?(page_name)
      File.join(@pages_dir, category, 'index.md')
    else
      File.join(@pages_dir, category, "#{page_name}.md")
    end
  end

  def write_migrated_file(target_file, front_matter, content)
    # Ensure target directory exists
    FileUtils.mkdir_p(File.dirname(target_file))

    # Write file with front matter
    File.open(target_file, 'w') do |f|
      f.write("---\n")
      f.write(YAML.dump(front_matter))
      f.write("---\n\n")
      f.write(content)
    end
  end

  def create_category_indexes
    puts "\nCreating category index pages..."

    @category_mapping.values.uniq.each do |category|
      create_category_index(category)
    end
  end

  def create_category_index(category)
    index_file = File.join(@pages_dir, category, 'index.md')

    # Skip if already exists (was created by migration)
    return if File.exist?(index_file)

    category_data = {
      'commands' => {
        title: 'Comandos Claude Code',
        description: 'Guía completa de comandos de alto valor y workflows automatizados',
        icon: '⌨️'
      },
      'agents' => {
        title: 'Agentes Especialistas',
        description: '33+ agentes organizados por valor y caso de uso específico',
        icon: '👥'
      },
      'workflows' => {
        title: 'Workflows AI-First',
        description: 'Metodologías y flujos de trabajo para desarrollo con IA',
        icon: '🔄'
      },
      'best-practices' => {
        title: 'Mejores Prácticas',
        description: 'Patrones, técnicas y recomendaciones para desarrollo efectivo',
        icon: '⭐'
      }
    }

    data = category_data[category] || { title: category.capitalize, description: '', icon: '📁' }

    front_matter = {
      'layout' => 'docs',
      'title' => data[:title],
      'category' => category,
      'permalink' => "/#{category}/",
      'description' => data[:description],
      'toc' => false
    }

    content = <<~CONTENT
      # #{data[:icon]} #{data[:title]}

      #{data[:description]}

      ## Contenido Disponible

      {% assign category_pages = site.pages | where: "category", "#{category}" %}
      {% if category_pages.size > 0 %}
        <div class="pages-grid">
          {% for page in category_pages %}
            {% unless page.url == page.url %}
              <div class="page-card">
                <h3><a href="{{ page.url }}">{{ page.title }}</a></h3>
                {% if page.description %}
                  <p>{{ page.description }}</p>
                {% endif %}
                {% if page.tags %}
                  <div class="tags">
                    {% for tag in page.tags %}
                      <span class="tag">{{ tag }}</span>
                    {% endfor %}
                  </div>
                {% endif %}
              </div>
            {% endunless %}
          {% endfor %}
        </div>
      {% else %}
        <p>Contenido próximamente...</p>
      {% endif %}

      ---

      _📝 ¿Tienes sugerencias para esta sección? [Abre un issue](https://github.com/trivance-ai/trivance-ai-orchestrator/issues/new)_
    CONTENT

    write_migrated_file(index_file, front_matter, content)
    puts "  ✓ Created category index: #{index_file}"
  end
end

# Run migration if script is executed directly
if __FILE__ == $0
  migrator = ContentMigrator.new
  success = migrator.migrate_all

  if success
    puts "\n🎉 Content migration completed successfully!"
    puts "\nNext steps:"
    puts "1. Review generated files in docs/pages/"
    puts "2. Build Jekyll site: bundle exec jekyll build"
    puts "3. Test local site: bundle exec jekyll serve"
  else
    puts "\n❌ Content migration failed!"
    exit 1
  end
end