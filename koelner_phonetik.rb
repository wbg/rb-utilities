# Copyright (c) 2009 Roman Weinberger <rw@roman-weinberger.net>
#
# Permission is hereby granted, free of charge, to any person obtaining 
# a copy of this software and associated documentation files (the "Software"), 
# to deal in the Software without restriction, including without limitation the 
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or 
# sell copies of the Software, and to permit persons to whom the Software is 
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in 
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS 
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR 
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER 
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION 
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
class KoelnerPhonetik
  UMLAUTS = { 'ä' => 'a', 'ö' => 'o', 'ü' => 'u', 'ß' => 'ss', 'ph' => 'f' }
  SIMPLE_CODES = { 
    /(a|e|i|j|o|u|y)/   => '0',
    /(h)/               => '',
    /(b|p)/             => '1',
    /(d|t)/             => '2',
    /(f|v|w|g|k|q)/     => '3',
    /(x)/               => '48',
    /(l)/               => '5',
    /(m|n)/             => '6',
    /(r)/               => '7',
    /(c|s|z)/             => '8',
  }
  BEFORE_EX = [ [/(dc|ds|dz|tc|ts|tz)/, '8'], [/(ca|ch|ck|cl|co|cq|cu|cx)/, '4'] ]
  FOLLOW = /(sc|zc|cx|kx|qx)/ #8 
  START_BEFORE = /(ca|ch|ck|cl|co|cq|cr|cu|cx)/ # 4

  def self.compute(s)
    sa = clean_string(s).scan(/./)
    return "" if sa.empty?
    res = Array.new sa.size
    sa.each_index do |i|
      b = sa[i]
      c = sa.size > i+1 ? sa[i+1] : ""
      a = i > 0 ? sa[i-1] : ""
      if i == 0  and b+c == "cr"
        res[0] = '4' 
      elsif i == 0 and (b+c =~ START_BEFORE) == 0 
        res[0] = '4'
      elsif i > 0 and (a+b =~ FOLLOW) == 0
        res[i] = '8'
      else
        if (b+c =~ BEFORE_EX[0][0]) == 0
          res[i] = BEFORE_EX[0][1]
        elsif (b+c =~ BEFORE_EX[1][0]) == 0
          res[i] = BEFORE_EX[1][1]
        else
          SIMPLE_CODES.each_pair do |r,v|
            if (b =~ r) == 0
              res[i] = v
              break
            end
          end
        end
      end
    end
    res.compact!
    ret = res.empty? ? [] : [res[0]]
    # remove duplicates
    (1..(res.size-1)).each { |i| ret.push res[i] unless res[i] == res[i-1] }
    ret.shift.to_s + ret.join.gsub('0','')
  end

private
  def self.clean_string(s)
    s.downcase.gsub(/ä|ö|ü|ß|ph/) {|s| UMLAUTS[s]}
  end
end

class String
  def koelner_phonetik
    KoelnerPhonetik.compute(to_s)
  end
  def sounds_like?(s, style=:koelner)
    if style==:koelner 
      to_s.koelner_phonetik == s.koelner_phonetik
    else
      to_s == s.to_s
    end
  end
end