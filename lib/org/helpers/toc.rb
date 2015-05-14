module Org::Helpers
  module TOC
    class Node
      attr_accessor :id
      attr_accessor :title

      attr_accessor :parent
      attr_accessor :children

      def initialize(id: nil, title: nil)
        self.children = []
        self.id       = id
        self.title    = title
      end

      def html
        html_particles.join("\n")
      end

      def html_particles(level: 0)
        particles = []

        if title
          particles << %{#{indent(level)}<li>}
          particles << %{#{indent(level + 1)}<a href="##{id}">#{title}</a>}
        end

        if children.size > 0
          particles << %{#{indent(level + 1)}<ol>}
          children.each do |child|
            particles += child.html_particles(level: level + 2)
          end
          particles << %{#{indent(level + 1)}</ol>}
        end

        if title
          particles << %{#{indent(level)}</li>}
        end

        particles
      end

      def indent(level)
        "  " * level
      end

      def text
        text_particles.join("\n")
      end

      def text_particles(level: 0)
        particles = []
        particles << "#{indent(level)}- #{title}" if title

        children.each do |child|
          particles += child.text_particles(level: level + 1)
        end

        particles
      end
    end

    def build_toc(content)
      headers = content.scan(%r{<h([0-9]) id="(.*)">(.*)</h[0-9]>})

      root = Node.new

      last_node = root
      last_level = 1

      headers.each do |level, id, title|
        level = level.to_i
        node = Node.new(id: id, title: title)

        # ascend if we denested
        (last_level - level + 1).times { last_node = last_node.parent }

        node.parent = last_node
        last_node.children << node

        last_level = level
        last_node = node
      end

      root.html
    end
  end
end
