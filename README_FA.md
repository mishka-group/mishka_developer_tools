# کتابخانه و  ابزار های توسعه پروژه الیکسیر
اخیرا تیم [میشکا](https://github.com/mishka-group) در حال توسعه [سیستم مدیریت محتوا](https://github.com/mishka-group/mishka-cms) می باشد که تصمیم بر این گرفتیم برخی از شبهه کد های آن را استخراج  و تبدیل به افزونه قابل نصب در پروژه های الیکسیر کنیم.در حقیقت این کتابخانه تشکیل شده از چند ماکرو و فانکشن برای راحتی کار با بانک اطلاعاتی و دیگر بخش ها یک پروژه می باشد.

## نصب
```elixir
def deps do
  [
    {:mishka_developer_tools, "~> 0.0.6"}
  ]
end
```
> برای مشاهده اسناد این کتابخانه به لینک https://hexdocs.pm/mishka_developer_tools مراجعه کنید.

##  پیاده‌سازی سریع CRUD 
برای پیاده‌سازی توابع اولیه ساخت CRUD فقط کافی می باشد موارد زیر را به ترتیب انجام بدهید.

### فراخوانی ماکرو 
```elixir
 use MishkaDeveloperTools.DB.CRUD,
    module: YOUR_SCHEMA,
    error_atom: :YOUR_REQUESTED_ATOM,
    repo: YOUR_REPO_MODULE
```
شما بعد از فراخوانی تابع `__using__` کافی می باشد سه پارامتر بالا از جمعه {`module`, `error_atom`, `repo`} را ارزش گذاری نمایید. و همینطور برای نظم بخشیدن به ساختار کد های خودتان می توانید `@behaviour` که در این کتابخانه نوشته شده است را نیز در فایل خود فراخوانی کنید.
```elixir
 @behaviour MishkaDeveloperTools.DB.CRUD
```
و حال نوبت به این رسیده است که ماکرو های `CRUD` را فراخوانی کنید. توجه داشته باشید این ماکرو ها حتما نیازی ندارند که در یک تابع قرار داده بشود

```elixir
  @doc delegate_to: {MishkaDeveloperTools.DB.CRUD, :crud_add, 1}
  def create(attrs) do
    crud_add(attrs)
  end

  @doc delegate_to: {MishkaDeveloperTools.DB.CRUD, :crud_add, 1}
  def create(attrs, allowed_fields) do
    crud_add(attrs, allowed_fields)
  end

  @doc delegate_to: {MishkaDeveloperTools.DB.CRUD, :crud_edit, 1}
  def edit(attrs) do
    crud_edit(attrs)
  end

  @doc delegate_to: {MishkaDeveloperTools.DB.CRUD, :crud_edit, 1}
  def edit(attrs, allowed_fields) do
    crud_edit(attrs, allowed_fields)
  end

  @doc delegate_to: {MishkaDeveloperTools.DB.CRUD, :crud_delete, 1}
  def delete(id) do
    crud_delete(id)
  end

  @doc delegate_to: {MishkaDeveloperTools.DB.CRUD, :crud_get_record, 1}
  def show_by_id(id) do
    crud_get_record(id)
  end
```

لازم به ذکر است ماکرو دیگری نیز وجود دارد که برای آن `callback` درست نگردیده است ولی می توانید به صورت زیر فراخوانی گردد
```elixir
crud_get_by_field("alias_link", alias_link)
```
در ماکرو بالا بجای `alias_link` می توانید فیلد مورد نظری که می خواهد به صورت `get_by` فراخوانی کنید را قرار بدهید.