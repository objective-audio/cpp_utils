# cpp_utils

C++のユーティリティー集

## yas_boolean

boolをvectorで扱うためのクラス。1要素のサイズを`sizeof(bool)`で確保できる。

```cpp
std::vector<yas::boolean> vec{true, false};

vec[0]; // -> true
vec[1]; // -> false
sizeof(vec[0]); // -> sizeof(bool)
```

## yas_base

参照型を実現するための基底クラス。

外部からアクセスするためのクラスは`yas::base`を継承し、実体となるクラスは`yas::base::impl`を継承する。

```cpp
struct derived : yas::base {
    struct impl : base::impl {
        float value;
        
        impl(float value) : value(value) {
        }
    };
    
    derived(float value) : base(std::make_shared<impl>(value)) {
    }

    void set_value(float value) {
        impl_ptr<impl>()->value = value;
    }

    float value() const {
        return impl_ptr<impl>()->value;
    }
};
```

## yas_cf_ref

CFオブジェクトを保持するためのクラス。`yas::base`を継承している。

通常の生成ではオーナーシップを移動しないが、`make_cf_ref`ではオーナーシップを移動する。

```cpp
// オーナーシップを移動しないで生成する場合
auto arrayObj = CFArrayCreate(nullptr, nullptr, 0, nullptr);
cf_ref<CFArrayRef> cf_obj(arrayObj);
CFRelease(arrayObj)

// オーナーシップを移動して生成する場合
auto cf_obj = make_cf_ref(CFArrayCreate(nullptr, nullptr, 0, nullptr));
```

## yas_cf_utils

CoreFoundation関連のユーティリティ集。

* `CFStringRef`と`std::string`の変換
* `CFArrayRef`と`std::vector`の変換
* 数値と`CFNumber`の変換

## yas_chain

複数の処理を連結して実行させることができるクラス。

処理を記述する`std::function`の引数には`chain_context`が渡され、`next()`を呼ぶと次の処理が実行され、`stop()`を呼ぶとそこで処理が打ち切られる。

```cpp
int defaultValue = 1; // contextの値の初期値

auto func1 = [](yas::chain_context<int> context){
    context.get(); // -> 1
    
    context.set(2);
    
    context.next(); // 次の処理へ進む
};

auto func2 = [](yas::chain_context<int> context){
    context.get(); // -> 2
    
    context.next(); // 次の処理へ進む（次は無いので終わる）
};

yas::chain(defaultValue, {func1, func2}); // 実行
```

## yas_delaying_caller

実行したい処理をスタックして遅らせることができるクラス。

```cpp
delaying_caller caller;

caller.push(); // カウントを1上げる

caller.request([](){
    // 処理
});

caller.pop(); // カウントが1下がって0になる。リクエストされた処理が呼ばれ、処理はクリアされる

caller.request([](){
    // 処理
}); // カウントが0なので、この時点ですぐに処理が呼ばれる
```

## yas_each_dictionary

`CFDirectoryRef`を`iterator`で扱えるようにするクラス。

```cpp
NSDictionary *dict = @{ @"a": @"1", @"b": @"2", @"c": @"3" };

for (auto &pair : yas::each_dictionary{(__bridge CFDictionaryRef)dict}) {
    // 要素に対する処理
}
```

## yas_each_index

deprecated

`iterator`でインデックスを扱えるようにするクラス。fast_eachの使用を推奨。

## yas_exception

例外を発生させる関数群。

* **raise_with_reason** -> 文字列を指定して例外を発生させる
* **raise_if_main_thread** -> メインスレッドで呼ばれたら例外を発生させる
* **raise_if_sub_thread** -> メインでないスレッドで呼ばれたら例外を発生させる

## yas_flagset

テンプレートパラメータで指定したenum型の要素を持つ`bitset`を持つクラス。enumには要素の数と同じ値となる`count`を宣言しておく。

```cpp
enum class test_enum : std::size_t {
    flag_a,
    flag_b,

    count,
};

yas::flagset<test_enum> flagset;
flagset.set(test_enum::flag_a);

yas::flagset<test_enum> flagset2;
flagset2.set(test_enum::flag_a);

yas::flagset<test_enum> flagset3;
flagset3.set(test_enum::flag_b);

// 指定した値のビットが立っているか調べる
flagset.test(test_enum::flag_a); // trueを返す
flagset.test(test_enum::flag_b); // falseを返す

// 引数に渡したflagsetとAND演算をしてビットが立っているかを調べる
flagset.and_test(flagset2); // trueを返す
flagset.and_test(flagset3); // falseを返す
```

## yas_flex_ptr

deprecated

どの数値のポインタ型としても扱えるようにするクラス。

## yas_objc_cast

Objective-Cのオブジェクトに対して`isKindOfClass:`を呼んでテンプレートパラメータの型にキャストできればその型のオブジェクトとして返す。キャストできなければ`nil`を返す。

```cpp
NSMutableArray *array = [NSMutableArray array];

auto castedObj1 = objc_cast<NSArray>(array); // -> NSArrayのオブジェクトを返す
auto castedObj2 = objc_cast<NSString>(array); // -> nilを返す
```

## yas_objc_ptr

Objective-Cのオブジェクトを保持するためのクラス。`yas::base`を継承している。

通常の生成ではオーナーシップを移動しないが、`make_objc_ptr`ではオーナーシップを移動する。

`make_objc_ptr`の`std::function`を引数に取るバージョンでは`autorelease`を剥がしてObjective-Cのオブジェクトを保持する。

```cpp
// オーナーシップを移動して生成
auto objc_obj1 = make_objc_ptr([[NSObject alloc] init]);

// autoreleaseを剥がしてオーナーシップを持ち生成
auto objc_obj2 = yas::make_objc_ptr([](){ return [NSArray array]; });
```

## yas_observing

通知を行うクラス群。

通知を送信するクラスは`yas::subject`、通知を受信するクラスは`yas::observer`。

それぞれ1つ目のテンプレートパラメータは`value`の型、2つ目のパラメータは`key`の型。2つ目は省略すると`std::string`となる。

`subject`は`observer`のオーナーシップを持たない。明示的に`observer`を保持していないと通知が呼ばれないので注意。


```cpp
yas::subject<int> subject;
    
yas::observer<int> observer = subject.make_observer("key", [](yas::observer<int>::change_context const &context){
    std::cout << "key:" << context.key << " value:" << context.value << std::endl;
});

subject.notify("key", 1);
```

## yas_operation

非同期処理をおこなうクラス群。処理は`operation`で持ち`operation_queue`に追加すると非同期で処理をする。

```cpp
yas::operation_queue queue;
yas::operation op([](yas::operation const &) {
    // 別スレッドで実行される処理
});
queue.push_back(op);
```

## yas_fast_each

インデックスやポインタを走査するためのクラス。高速に処理するために値のアクセスやインデックスの移動はマクロを使う。

```cpp
// インデックスを走査する場合
auto each = make_fast_each(5);
    
while (yas_fast_each_next(each)) {
    std::cout << "idx:" << yas_fast_each_index(each) << std::endl;
}

// ポインタを走査する場合
int array[3] = {2, 4, 6};

auto each = make_fast_each(array, 3);

while (yas_fast_each_next(each)) {
    std::cout << "idx:" << yas_fast_each_index(each) << " value:" << yas_fast_each_value(each) << std::endl;
}
```

## yas_property

任意の型の値を保持するクラス。`observing`による通知や、値の検証などの機能を持つ。

```cpp
yas::property<float> property;

property.set_value(1.0f);

property.value(); // -> 1.0f
```

```cpp
yas::property<bool, int> property({.value = false, .key = 1});

auto observer = property.subject().make_wild_card_observer([](auto const &context) {
    std::cout << "method:" << yas::to_string(context.key); // -> "will_change" or "did_change"
    std::cout << " key:" << context.value.property.key(); // -> 1
    std::cout << " value:" << context.value.property.value() << std::endl; // will -> false, did -> true
});

property.set_value(true);
```

## yas_protocol

プロトコルを実現するクラス。`yas::base`を継承したクラスに対して多重継承して必要なインターフェースを持つことを定義する。

```cpp
struct sample_protocol : yas::protocol {
    struct impl : yas::protocol::impl {
        virtual int required_function() = 0;
        virtual int optional_function() {
            return 1;
        }
    };
    
    sample_protocol(std::shared_ptr<impl> impl) : protocol(std::move(impl)) {
    }
    
    int required_function() {
        return impl_ptr<impl>()->required_function();
    }
    
    int optional_function() {
        return impl_ptr<impl>()->optional_function();
    }
};

struct sample_object : yas::base {
    struct impl : yas::base::impl, sample_protocol::impl {
        int required_function() override {
            return 2;
        }
    };
    
    sample_object() : base(std::make_shared<impl>()) {
    }
    
    sample_protocol protocol() {
        return sample_protocol{impl_ptr<sample_protocol::impl>()};
    }
};

sample_object obj;
obj.protocol().required_function(); // -> 2
obj.protocol().optional_function(); // -> 1
```

## yas_result

成功か失敗かを表すクラス。テンプレートパラメータの1つめが成功の型、2つめが失敗の型となる。2つの型は違っている必要がある。

成功の場合は`value()`に値があり、失敗の場合は`error()`に値がある。両方に値を持つことはない。

`operator bool()`は成功ならば`true`を返し、失敗ならば`false`を返す。

```cpp
std::string value("success");
    
yas::result<std::string, int> result1(value);
    
if (result1) { // 通る
    std::cout << "result1.value=" << result1.value() << std::endl; // -> result1.value=success
}
    
int error = 1;
    
yas::result<std::string, int> result2(error);
    
if (!result2) { // 通る
    std::cout << "result2.error=" << result2.error() << std::endl; // -> result2.error=1
}
```

## yas_stl_utils

STLをサポートする関数群。

* **min_empty_key** -> mapのkeyで使われていない最小の整数を返す。keyは整数型のみ。
* **index** -> vectorの要素のインデックスを返す。見つからなければ`nullopt`を返す。
* **filter** -> predicateでtrueを返した要素だけのコレクションを返す。predicateの引数は要素の値そのもの。
* **erase_if** -> predicateでtrueを返した要素をコレクションから削除する。predicateの引数はイテレータ。
* **erase_if_exists** -> keyに一致するmapの要素を削除する。
* **for_each** -> functionを要素の数だけ繰り返す。functionの引数はイテレータ。
* **connect** -> 2つのvectorを合体したvectorを返す。
* **move_back_insert** -> 第2引数のvectorを第1引数のvectorの後ろにmoveして連結する。
* **move_insert** -> 要素をコレクションにmoveしてinsertする。第3引数
* **pull** -> unordered_mapの要素を取得して削除する。
* **replace** -> mapの要素を置き換える。
* **to_vector** -> コレクションの要素を元にvectorを作る
* **to_unordered_set** -> vectorからunordered_setを作る。
* **to_map** -> vectorからmapを作る。functionでは要素からkeyを返す。
* **to_lower** -> 小文字にした文字列を返す。
* **replaced** -> sourceに含まれるtargetをreplacementに置き換えた文字列を返す。
* **joined** -> componentsをseparatorでつなげた文字列を返す。
* **to_weak** -> std::shared_ptrをstd::weak_ptrに変換する。

## yas_to_bool

enumの値をboolに変換する。数値的に0であればfalse、0以外であればtrueを返す。

```cpp
enum class test_enum {
    zero,
    one,
};

yas::to_bool(test_enum::zero); // -> false
yas::to_bool(test_enum::one); // -> true
```
## yas_type_traits

* **has_operator_bool** -> 型に`operator bool()`が実装されているか調べる。

## yas_types

* **nullopt** -> `std::experimental::nullopt`を`yas::nullopt`で書ける。

## yas_unless

`bool`の判定を逆にするクラス。

```cpp
yas::unless(false) // -> true
yas::unless(true) // -> false
```

## yas_version

バージョンを表すクラス。

```cpp
yas::version version{"1.2.3"};

version.str() // -> "1.2.3"
version.numbers() // -> {1, 2, 3}
```

## yas_to_string

* **to_string** -> `yas`のnamespaceでそのまま`std::to_string`を呼ぶ関数。
