require "hpricot"

module AppHelpers

  # Like the Rails _truncate_ helper but doesn't break HTML tags or entities.
  def better_truncate(text, max_length = 30, ellipsis = "...")
    return if text.nil?

    doc = Hpricot(text.to_s)
    ellipsis_length = Hpricot(ellipsis).inner_text.chars.length
    content_length = doc.inner_text.chars.length
    actual_length = max_length - ellipsis_length

    content_length > max_length ? doc.truncate(actual_length, logger).inner_html + ellipsis : text.to_s
  end

  module HpricotTruncator
    module NodeWithChildren
      def truncate(max_length, logger)
        return self if inner_text.chars.length <= max_length
        truncated_node = self.dup
        truncated_node.children = []
        each_child do |node|
          remaining_length = max_length - truncated_node.inner_text.chars.length
          break if remaining_length == 0
          truncated_node.children << node.truncate(remaining_length, logger)
        end
        truncated_node
      end
    end

    module TextNode
      def truncate(max_length, logger)
        Hpricot::Text.new(content[/\A.{#{max_length}}\w*\;?/m][/.*[\w\;]/m])
      end
    end

    module IgnoredTag
      def truncate(max_length)
        self
      end
    end
  end

  Hpricot::Doc.send(:include,       HpricotTruncator::NodeWithChildren)
  Hpricot::Elem.send(:include,      HpricotTruncator::NodeWithChildren)
  Hpricot::Text.send(:include,      HpricotTruncator::TextNode)
  Hpricot::BogusETag.send(:include, HpricotTruncator::IgnoredTag)
  Hpricot::Comment.send(:include,   HpricotTruncator::IgnoredTag)
  
end