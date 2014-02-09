module Org::Helpers
  module Reading
    def count_by_year(books)
      book_count_by_year = {}
      books.reverse.each do |b|
        year = Time.new(b[:occurred_at].year)
        book_count_by_year[year] ||= 0
        book_count_by_year[year] += 1
      end
      book_count_by_year
    end

    def format_isbn13(isbn)
      if isbn.length == 13
        isbn[0..2] + "-" + isbn[3] + "-" + isbn[4..6] +
          "-" + isbn[7..11] + "-" + isbn[12]
      else
        nil
      end
    end
  end
end
