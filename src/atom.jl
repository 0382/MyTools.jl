using Markdown
"""
    struct Element
        atomic_number::Int
        symbol_name::String
        chinese_name::String
        english_name::String
        latin_name::String
        pinyin_name::String
    end # struct Element
元素结构体，包含元素的原子序数，元素符号，中文名，英文名，拉丁文名，拼音名。

构造函数：
```julia
Element(Z, sym, chinese, english, latin, pinyin)
Element(ele::Element)                         # identity
Element(Z::Integer)                           # 从原子序数构造
Element(name::Union{AbstractString, Symbol})  # 从任何名称构造，比如 "Fe", "铝", "Oxygen"
```
"""
struct Element
    atomic_number::Int
    symbol_name::String
    chinese_name::String
    english_name::String
    latin_name::String
    pinyin_name::String
    Element(Z, sym, chinese, english, latin, pinyin) = new(Z, sym, chinese, english, latin, pinyin)
end # struct Element

"不存在的元素"
const NoneElement = Element(-1, "", "", "", "", "")

"判断是否为不存在的元素"
is_none(ele::Element)::Bool = !(1 <= ele.atomic_number <= 118)

"元素周期表"
const element_table = [
    Element(1, "H", "氢", "Hydrogen", "Hydrogenium", "qīng"),
    Element(2, "He", "氦", "Helium", "Helium", "hài"),
    Element(3, "Li", "锂", "Lithium", "Lithium", "lǐ"),
    Element(4, "Be", "铍", "Beryllium", "Beryllium", "pí"),
    Element(5, "B", "硼", "Boron", "Borum", "péng"),
    Element(6, "C", "碳", "Carbon", "Сarbonium (Carboneum)", "tàn"),
    Element(7, "N", "氮", "Nitrogen", "Nitrogenium", "dàn"),
    Element(8, "O", "氧", "Oxygen", "Oxygenium", "yǎng"),
    Element(9, "F", "氟", "Fluorine", "Fluorum", "fú"),
    Element(10, "Ne", "氖", "Neon", "Neon", "nǎi"),
    Element(11, "Na", "钠", "Sodium", "Natrium", "nà"),
    Element(12, "Mg", "镁", "Magnesium", "Magnesium", "měi"),
    Element(13, "Al", "铝", "Aluminum", "Aluminium", "lǚ"),
    Element(14, "Si", "硅", "Silicon", "Silicium", "guī"),
    Element(15, "P", "磷", "Phosphorus", "Phosphorus", "lín"),
    Element(16, "S", "硫", "Sulfur", "Sulphuris", "liú"),
    Element(17, "Cl", "氯", "Chlorine", "Сhlorum", "lǜ"),
    Element(18, "Ar", "氩", "Argon", "Argon", "yà"),
    Element(19, "K", "钾", "Potassium", "Kalium", "jiǎ"),
    Element(20, "Ca", "钙", "Calcium", "Сalcium", "gài"),
    Element(21, "Sc", "钪", "Scandium", "Scandium", "kàng"),
    Element(22, "Ti", "钛", "Titanium", "Titanium", "tài"),
    Element(23, "V", "钒", "Vanadium", "Vanadium", "fán"),
    Element(24, "Cr", "铬", "Chromium", "Chromium", "gè"),
    Element(25, "Mn", "锰", "Manganese", "Manganum", "měng"),
    Element(26, "Fe", "铁", "Iron", "Ferrum", "tiě"),
    Element(27, "Co", "钴", "Cobalt", "Cobaltum", "gǔ"),
    Element(28, "Ni", "镍", "Nickel", "Niccolum", "niè"),
    Element(29, "Cu", "铜", "Copper", "Cuprum", "tóng"),
    Element(30, "Zn", "锌", "Zinc", "Zincum", "xīn"),
    Element(31, "Ga", "镓", "Gallium", "Gallium", "jiā"),
    Element(32, "Ge", "锗", "Germanium", "Germanium", "zhě"),
    Element(33, "As", "砷", "Arsenic", "Arsenicum", "shēn"),
    Element(34, "Se", "硒", "Selenium", "Selenium", "xī"),
    Element(35, "Br", "溴", "Bromine", "Bromum", "xiù"),
    Element(36, "Kr", "氪", "Krypton", "Krypton", "kè"),
    Element(37, "Rb", "铷", "Rubidium", "Rubidium", "rú"),
    Element(38, "Sr", "锶", "Strontium", "Strontium", "sī"),
    Element(39, "Y", "钇", "Yttrium", "Yttrium", "yǐ"),
    Element(40, "Zr", "锆", "Zirconium", "Zirconium", "gào"),
    Element(41, "Nb", "铌", "Niobium", "Niobium", "ní"),
    Element(42, "Mo", "钼", "Molybdenum", "Molybdaenum", "mù"),
    Element(43, "Tc", "锝", "Technetium", "Technetium", "dé"),
    Element(44, "Ru", "钌", "Ruthenium", "Ruthenium", "liǎo"),
    Element(45, "Rh", "铑", "Rhodium", "Rhodium", "lǎo"),
    Element(46, "Pd", "钯", "Palladium", "Palladium", "bǎ"),
    Element(47, "Ag", "银", "Silver", "Argentum", "yín"),
    Element(48, "Cd", "镉", "Cadmium", "Cadmium", "gé"),
    Element(49, "In", "铟", "Indium", "Indium", "yīn"),
    Element(50, "Sn", "锡", "Tin", "Stannum", "xī"),
    Element(51, "Sb", "锑", "Antimony", "Stibium", "tī"),
    Element(52, "Te", "碲", "Tellurium", "Tellurium", "dì"),
    Element(53, "I", "碘", "Iodine", "Iodium", "diǎn"),
    Element(54, "Xe", "氙", "Xenon", "Xenon", "xiān"),
    Element(55, "Cs", "铯", "Caesium", "Caesium", "sè"),
    Element(56, "Ba", "钡", "Barium", "Barium", "bèi"),
    Element(57, "La", "镧", "Lanthanum", "Lanthanum", "lán"),
    Element(58, "Ce", "铈", "Cerium", "Cerium", "shì"),
    Element(59, "Pr", "镨", "Praseodymium", "Praseodymium", "pǔ"),
    Element(60, "Nd", "钕", "Neodymium", "Neodymium", "nǚ"),
    Element(61, "Pm", "钷", "Promethium", "Promethium", "pǒ"),
    Element(62, "Sm", "钐", "Samarium", "Samarium", "shān"),
    Element(63, "Eu", "铕", "Europium", "Europium", "yǒu"),
    Element(64, "Gd", "钆", "Gadolinium", "Gadolinium", "gá"),
    Element(65, "Tb", "铽", "Terbium", "Terbium", "tè"),
    Element(66, "Dy", "镝", "Dysprosium", "Dysprosium", "dī"),
    Element(67, "Ho", "钬", "Holmium", "Holmium", "huǒ"),
    Element(68, "Er", "铒", "Erbium", "Erbium", "ěr"),
    Element(69, "Tm", "铥", "Thulium", "Thulium", "diū"),
    Element(70, "Yb", "镱", "Ytterbium", "Ytterbium", "yì"),
    Element(71, "Lu", "镥", "Lutetium", "Lutetium", "lǔ"),
    Element(72, "Hf", "铪", "Hafnium", "Hafnium", "hā"),
    Element(73, "Ta", "钽", "Tantalum", "Tantalum", "tǎn"),
    Element(74, "W", "钨", "Tungsten", "Wolframium", "wū"),
    Element(75, "Re", "铼", "Rhenium", "Rhenium", "lái"),
    Element(76, "Os", "锇", "Osmium", "Osmium", "é"),
    Element(77, "Ir", "铱", "Iridium", "Iridium", "yī"),
    Element(78, "Pt", "铂", "Platinum", "Platinum", "bó"),
    Element(79, "Au", "金", "Gold", "Aurum", "jīn"),
    Element(80, "Hg", "汞", "Mercury", "Hydrargyrum", "gǒng"),
    Element(81, "Tl", "铊", "Thallium", "Thallium", "tā"),
    Element(82, "Pb", "铅", "Lead", "Plumbum", "qiān"),
    Element(83, "Bi", "铋", "Bismuth", "Bisemutum (Bismuthum, Bismutum)", "bì"),
    Element(84, "Po", "钋", "Polonium", "Polonium", "pō"),
    Element(85, "At", "砹", "Astatine", "Astatum", "ài"),
    Element(86, "Rn", "氡", "Radon", "Radon", "dōng"),
    Element(87, "Fr", "钫", "Francium", "Francium", "fāng"),
    Element(88, "Ra", "镭", "Radium", "Radium", "léi"),
    Element(89, "Ac", "锕", "Actinium", "Actinium", "ā"),
    Element(90, "Th", "钍", "Thorium", "Thorium", "tǔ"),
    Element(91, "Pa", "镤", "Protactinium", "Protactinium", "pú"),
    Element(92, "U", "铀", "Uranium", "Uranium", "yóu"),
    Element(93, "Np", "镎", "Neptunium", "Neptunium", "ná"),
    Element(94, "Pu", "钚", "Plutonium", "Plutonium", "bù"),
    Element(95, "Am", "镅", "Americium", "Americium", "méi"),
    Element(96, "Cm", "锔", "Curium", "Curium", "jú"),
    Element(97, "Bk", "锫", "Berkelium", "Berkelium", "péi"),
    Element(98, "Cf", "锎", "Californium", "Californium", "kāi"),
    Element(99, "Es", "锿", "Einsteinium", "Einsteinium", "āi"),
    Element(100, "Fm", "镄", "Fermium", "Fermium", "fèi"),
    Element(101, "Md", "钔", "Mendelevium", "Mendelevium", "mén"),
    Element(102, "No", "锘", "Nobelium", "Nobelium", "nuò"),
    Element(103, "Lr", "铹", "Lawrencium", "Lawrencium", "láo"),
    Element(104, "Rf", "𬬻", "Rutherfordium", "Rutherfordium", "lú"),
    Element(105, "Db", "𬭊", "Dubnium", "Dubnium", "dù"),
    Element(106, "Sg", "𬭳", "Seaborgium", "Seaborgium", "xǐ"),
    Element(107, "Bh", "𬭛", "Bohrium", "Bohrium", "bō"),
    Element(108, "Hs", "𬭶", "Hassium", "Hassium", "hēi"),
    Element(109, "Mt", "鿏", "Meitnerium", "Meitnerium", "mài"),
    Element(110, "Ds", "𫟼", "Darmstadtium", "Darmstadtium", "dá"),
    Element(111, "Rg", "𬬭", "Roentgenium", "Roentgenium", "lún"),
    Element(112, "Cn", "鎶", "Copernicium", "Copernecium", "gē"),
    Element(113, "Nh", "鉨", "Nihonium", "Nihonium", "nǐ"),
    Element(114, "Fl", "𫓧", "Flerovium", "Flerovium", "fū"),
    Element(115, "Mc", "镆", "Moscovium", "Moscovium", "mò"),
    Element(116, "Lv", "鉝", "Livermorium", "Livermorium", "lì"),
    Element(117, "Ts", "石田", "Tennessine", "Tennessine", "tián"),
    Element(118, "Og", "气奥", "Oganesson", "Oganneson", "ào")
]

"通过原子序数查找元素"
find_element_with_Z(Z::Integer) = (1 <= Z <= 118) ? element_table[Z] : NoneElement

"通过元素符号查找元素"
function find_element_with_symbol(sym::AbstractString)
    pos = findfirst(ele -> ele.symbol_name == sym, element_table)
    pos === nothing ? NoneElement : element_table[pos]
end

"通过元素中文名查找元素"
function find_element_with_chinese(chinese::AbstractString)
    pos = findfirst(ele -> ele.chinese_name == chinese, element_table)
    pos === nothing ? NoneElement : element_table[pos]
end

"通过元素英文名查找元素"
function find_element_with_english(english::AbstractString)
    pos = findfirst(ele -> ele.english_name == english, element_table)
    pos === nothing ? NoneElement : element_table[pos]
end

"通过元素拉丁文名查找元素"
function find_element_with_latin(latin::AbstractString)
    pos = findfirst(ele -> match(Regex("\\b" * latin * "\\b"), ele.latin_name) !== nothing, element_table)
    pos === nothing ? NoneElement : element_table[pos]
end

"通过元素拼音查找元素"
function find_element_with_pinyin(pinyin::AbstractString)
    pos = findfirst(ele -> ele.pinyin_name == pinyin, element_table)
    pos === nothing ? NoneElement : element_table[pos]
end

"""
    find_element(name::Union{Integer, AbstractString})
通过任何名称查找元素，包括使用原子序数
"""
function find_element(name::Union{Integer, AbstractString})
    name isa Integer && return find_element_with_Z(name)
    ele = find_element_with_symbol(name)
    is_none(ele) && (ele = find_element_with_chinese(name))
    is_none(ele) && (ele = find_element_with_english(name))
    is_none(ele) && (ele = find_element_with_latin(name))
    is_none(ele) && (ele = find_element_with_pinyin(name))
    return ele
end

Element(ele::Element) = ele
Element(Z::Integer) = find_element_with_Z(Z)
Element(name::Union{AbstractString, Symbol}) = find_element(string(name))

const ElementConstructType = Union{Element, Integer, AbstractString, Symbol}
"获取原子序数"
getZ(ele::ElementConstructType) = Element(ele).atomic_number
"获取原子序数"
atomic_number(ele::ElementConstructType) = Element(ele).atomic_number
"获取元素符号"
symbol(ele::ElementConstructType) = Element(ele).symbol_name
"获取元素中文名"
chinese(ele::ElementConstructType) = Element(ele).chinese_name
"获取元素英文名"
english(ele::ElementConstructType) = Element(ele).english_name
"获取元素拉丁文名"
latin(ele::ElementConstructType) = Element(ele).latin_name
"获取元素中文名拼音"
pinyin(ele::ElementConstructType) = Element(ele).pinyin_name

"""
    show_element_table(type::AbstractString="symbol")
打印元素周期表，`type`可以是`"symbol", "chinese"`两种
"""
function show_element_table(type::AbstractString="symbol")
    choose_field = nothing
    use_space = ""
    if type == "symbol"
        choose_field = symbol
        use_space = "  "
    elseif type == "chinese"
        choose_field = chinese
        use_space = "\u3000"
    else
        throw(ArgumentError("invalid element table type: $type"))
    end
    # 第一行
    str = @sprintf("%-2s%s %-2s\n", choose_field(Element(1)), repeat(" " * use_space, 16), choose_field(Element(2)))
    # 第二、三行
    for line = 2:3
        start = (line - 2) * 8 + 3
        for z = start:start+1
            str = str * @sprintf("%-2s ", choose_field(Element(z)))
        end
        str = str * repeat(use_space * " ", 10)
        for z = start+2:start+6
            str = str * @sprintf("%-2s ", choose_field(Element(z)))
        end
        str = str * @sprintf("%-2s\n", choose_field(Element(start+7)))
    end
    # 第四、五行
    for line = 4:5
        start = (line - 4) * 18 + 19
        for z = start:start+16
            str = str * @sprintf("%-2s ", choose_field(Element(z)))
        end
        str = str * @sprintf("%-2s\n", choose_field(Element(start + 17)))
    end
    # 第六、七行
    for line = 6:7
        start = (line - 6) * 32 + 55
        for z = start:start+2
            str = str * @sprintf("%-2s ", choose_field(Element(z)))
        end
        for z = start+17:start+30
            str = str * @sprintf("%-2s ", choose_field(Element(z)))
        end
        str = str * @sprintf("%-2s\n", choose_field(Element(start + 31)))
    end
    str = str * repeat(use_space * " ", 17) * use_space * "\n"
    # 附加行
    for line = 6:7
        str = str * repeat(use_space * " ", 2)
        start = (line - 6) * 32 + 57
        for z = start:start+14
            str = str * @sprintf("%-2s ", choose_field(Element(z)))
        end
        str = str * repeat(use_space * " ", 7)
        str = str * use_space * "\n"
    end
    print(str)
end