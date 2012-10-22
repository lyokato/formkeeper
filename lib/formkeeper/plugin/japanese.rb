require 'moji'

module FormKeeper
  module Filter
    class ZenToHan < Base
      def process(value)
        Moji.zen_to_han(value)
      end
    end 
    class HanToZen < Base
      def process(value)
        Moji.han_to_zen(value)
      end
    end 
    class KataToHira < Base
      def process(value)
        Moji.kata_to_hira(value)
      end
    end 
    class HiraToKata < Base
      def process(value)
        Moji.hira_to_kata(value)
      end
    end 
  end
  module Constraint
    class Kana < Base
      def validate(value, arg)
        # TODO support ZENKAKU/HANKAKU KIGOU \p{Punct}
        result = value =~ /^#{Moji.kana}+$/
        result = !result if !arg
        result
      end
    end
    class Hiragana < Base
      def validate(value, arg)
        # TODO support ZENKAKU/HANKAKU KIGOU \p{Punct}
        result = value =~ /^#{Moji.hira}+$/
        result = !result if !arg
        result
      end
    end
    class Katakana < Base
      def validate(value, arg)
        # TODO support ZENKAKU/HANKAKU KIGOU
        result = value =~ /^#{Moji.kata}+$/
        result = !result if !arg
        result
      end
    end
  end
end
FormKeeper::Validator.register_filter :hiragana2katakana, 
  FormKeeper::Filter::HiraToKata.new
FormKeeper::Validator.register_filter :katakana2hiragana, 
  FormKeeper::Filter::KataToHira.new
FormKeeper::Validator.register_filter :hankaku2zenkaku, 
  FormKeeper::Filter::HanToZen.new
FormKeeper::Validator.register_filter :zenkaku2hankaku, 
  FormKeeper::Filter::Zen2Han.new
FormKeeper::Validator.register_constraint :kana, 
  FormKeeper::Constraint::Kana.new
FormKeeper::Validator.register_constraint :hiragana, 
  FormKeeper::Constraint::Hiragana.new
FormKeeper::Validator.register_constraint :katakana,
  FormKeeper::Constraint::Katakana.new

