# Search Index Generator Plugin for Jekyll
# Generates a JSON search index for client-side search functionality
# Compatible with GitHub Pages safe mode restrictions

require 'json'

module Jekyll
  class SearchIndexGenerator < Generator
    safe true
    priority :low

    def generate(site)
      # Create search index data
      search_data = {
        'index' => []
      }

      # Process all pages and posts
      all_documents = site.pages + site.posts.docs

      all_documents.each do |doc|
        # Skip if document should not be indexed
        next if doc.data['search'] == false
        next if doc.data['sitemap'] == false
        next if doc.url.include?('404')

        # Extract searchable content
        content = extract_text_content(doc.content || '')
        title = doc.data['title'] || extract_title_from_content(doc.content || '')

        # Skip if no meaningful content
        next if title.empty? && content.length < 10

        # Determine category from URL or frontmatter
        category = determine_category(doc.url, doc.data)

        # Create search entry
        search_entry = {
          'id' => generate_id(doc.url),
          'title' => title.strip,
          'content' => truncate_content(content, 500),
          'category' => category,
          'url' => doc.url,
          'keywords' => extract_keywords(doc.data, content, title)
        }

        search_data['index'] << search_entry
      end

      # Add documentation from data file
      if site.data['docs'] && site.data['docs']['sections']
        site.data['docs']['sections'].each do |section|
          if section['pages']
            section['pages'].each do |page|
              search_entry = {
                'id' => page['id'],
                'title' => page['title'],
                'content' => page['excerpt'] || page['description'] || '',
                'category' => section['id'],
                'url' => "/#{section['id']}/#{page['id']}/",
                'keywords' => page['tags'] || []
              }
              search_data['index'] << search_entry
            end
          end
        end
      end

      # Write search index file
      search_file = File.join(site.dest, '_data', 'search.json')
      FileUtils.mkdir_p(File.dirname(search_file))
      File.write(search_file, JSON.pretty_generate(search_data))

      # Also create a copy in the source _data directory for development
      source_search_file = File.join(site.source, '_data', 'search.json')
      File.write(source_search_file, JSON.pretty_generate(search_data))

      Jekyll.logger.info "Search Index:", "Generated #{search_data['index'].length} entries"
    end

    private

    def extract_text_content(html_content)
      # Remove HTML tags and extract plain text
      text = html_content.gsub(/<[^>]*>/, ' ')

      # Clean up whitespace
      text = text.gsub(/\s+/, ' ').strip

      # Remove common Jekyll/Liquid tags
      text = text.gsub(/\{\{[^}]*\}\}/, '')
      text = text.gsub(/\{%[^%]*%\}/, '')

      text
    end

    def extract_title_from_content(content)
      # Try to find h1 heading
      h1_match = content.match(/<h1[^>]*>(.*?)<\/h1>/i)
      return strip_html(h1_match[1]) if h1_match

      # Try markdown h1
      h1_match = content.match(/^#\s+(.+)$/m)
      return h1_match[1].strip if h1_match

      # Fallback to first line
      first_line = content.split("\n").first || ''
      strip_html(first_line).strip
    end

    def strip_html(text)
      text.gsub(/<[^>]*>/, '').strip
    end

    def determine_category(url, frontmatter)
      # Check frontmatter first
      return frontmatter['category'] if frontmatter['category']

      # Determine from URL
      if url.include?('/commands/')
        'commands'
      elsif url.include?('/agents/')
        'agents'
      elsif url.include?('/workflows/')
        'workflows'
      elsif url.include?('/best-practices/')
        'best-practices'
      else
        'general'
      end
    end

    def generate_id(url)
      # Create a clean ID from URL
      id = url.gsub(/[\/\.]/, '-')
      id = id.gsub(/^-+|-+$/, '')
      id = id.gsub(/-+/, '-')
      id.empty? ? 'home' : id
    end

    def truncate_content(content, max_length)
      return content if content.length <= max_length

      # Try to cut at word boundary
      truncated = content[0, max_length]
      last_space = truncated.rindex(' ')

      if last_space && last_space > max_length * 0.8
        truncated = truncated[0, last_space]
      end

      truncated + '...'
    end

    def extract_keywords(frontmatter, content, title)
      keywords = []

      # Add tags from frontmatter
      keywords.concat(frontmatter['tags'] || [])
      keywords.concat(frontmatter['keywords'] || [])

      # Extract common words from title and content
      text = "#{title} #{content}".downcase

      # Common technical terms for Claude Code documentation
      technical_terms = [
        'implement', 'comando', 'agente', 'workflow', 'ai-first',
        'claude', 'code', 'desarrollo', 'programación', 'ia',
        'inteligencia', 'artificial', 'automatización'
      ]

      technical_terms.each do |term|
        keywords << term if text.include?(term)
      end

      # Remove duplicates and return
      keywords.uniq.compact
    end
  end
end