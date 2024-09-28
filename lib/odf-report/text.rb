module ODFReport
  class Text < Field
    attr_accessor :parser_builder

    def initialize(opts, &block)
      @parser_builder = opts.delete(:parser) || ->(value, node) { Parser::Default.new(value, node) }
      super
    end

    def replace!(doc, data_item = nil)
      return unless (node = find_text_node(doc))

      @parser = parser_builder.call(@data_source.value, node)

      @parser.paragraphs.each do |p|
        node.before(p)
      end

      node.remove
    end

    private

    def find_text_node(doc)
      texts = doc.xpath(".//text:p[text()='#{to_placeholder}']")
      if texts.empty?
        texts = doc.xpath(".//text:p/text:span[text()='#{to_placeholder}']")
        texts = if texts.empty?
          nil
        else
          texts.first.parent
        end
      else
        texts = texts.first
      end

      texts
    end
  end
end
