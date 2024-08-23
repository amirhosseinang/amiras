import asyncio
from telegram import Update, InlineKeyboardButton, InlineKeyboardMarkup
from telegram.ext import Application, CommandHandler, CallbackQueryHandler, MessageHandler, filters, ContextTypes
from collections import defaultdict

# توکن ربات
TOKEN = '6752548121:AAF4nLxpFPTQYkszKYObzr4r98HWNDqz8OE'

# اطلاعات پکیج‌ها با استفاده از اموجی‌ها
packages = {
    "1": {
        "name": "پکیج آموزشی صفر تا صد ترید",
        "description": "📊 توضیحات مربوط به پکیج آموزشی صفر تا صد ترید.",
        "price": "💵 200,000 تومان"
    },
    "2": {
        "name": "پکیج آموزشی ورد",
        "description": "📝 توضیحات مربوط به پکیج آموزشی ورد.",
        "price": "💵 150,000 تومان"
    },
    "3": {
        "name": "پکیج آموزشی پاورپوینت",
        "description": "📊 توضیحات مربوط به پکیج آموزشی پاورپوینت.",
        "price": "💵 180,000 تومان"
    },
    "4": {
        "name": "پکیج آموزشی کامپیوتر برای کودکان",
        "description": "👶💻 توضیحات مربوط به پکیج آموزشی کامپیوتر برای کودکان.",
        "price": "💵 100,000 تومان"
    },
    "5": {
        "name": "پکیج آموزشی زبان آلمانی",
        "description": "🇩🇪 توضیحات مربوط به پکیج آموزشی زبان آلمانی.",
        "price": "💵 250,000 تومان"
    }
}

# لیست شماره کارت‌ها و تعداد استفاده
card_numbers = [
    {"number": "1234-5678-9012-3456", "ali": "شماره کارت اول"},
    {"number": "2345-6789-0123-4567", "reza": "شماره کارت دوم"},
    # شماره کارت‌های بیشتر را در اینجا اضافه کنید
]

card_usage_count = defaultdict(int)

# تابع استارت
async def start(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    welcome_message = "به ربات آکادمی شکری خوش آمدید! 👋"
    await update.message.reply_text(welcome_message)

    keyboard = [
        [InlineKeyboardButton("📊 پکیج آموزشی صفر تا صد ترید", callback_data='1')],
        [InlineKeyboardButton("📝 پکیج آموزشی ورد", callback_data='2')],
        [InlineKeyboardButton("📊 پکیج آموزشی پاورپوینت", callback_data='3')],
        [InlineKeyboardButton("👶💻 پکیج آموزشی کامپیوتر برای کودکان", callback_data='4')],
        [InlineKeyboardButton("🇩🇪 پکیج آموزشی زبان آلمانی", callback_data='5')],
        [InlineKeyboardButton("en پکیج آموزشی زبان انگلیسی", callback_data='6')],
    ]

    reply_markup = InlineKeyboardMarkup(keyboard)
    await update.message.reply_text("لطفاً یکی از پکیج‌های زیر را انتخاب کنید:", reply_markup=reply_markup)

# تابع نمایش جزئیات پکیج
async def package_details(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    query = update.callback_query
    package_id = query.data

    package = packages.get(package_id, {})
    details_message = f"نام پکیج: {package.get('name', 'نامشخص')}\n\n{package.get('description', 'توضیحات نامشخص')}\n\nقیمت: {package.get('price', 'قیمت نامشخص')}"

    await query.message.reply_text(details_message)

    # دکمه خرید
    buy_keyboard = [
        [InlineKeyboardButton("🛒 خرید پکیج", callback_data=f'buy_{package_id}')]
    ]
    reply_markup = InlineKeyboardMarkup(buy_keyboard)
    await query.message.reply_text("برای خرید پکیج روی دکمه زیر کلیک کنید:", reply_markup=reply_markup)

# تابع خرید پکیج
async def buy_package(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    query = update.callback_query
    package_id = query.data.split('_')[1]

    # ارسال دکمه‌های انتخاب شماره کارت با نام
    card_buttons = [
        [InlineKeyboardButton(f"{card['ali']} - {card['number']}", callback_data=f'card_{i}')] for i, card in enumerate(card_numbers)
    ]

    card_keyboard = InlineKeyboardMarkup(card_buttons)
    await query.message.reply_text("💳 لطفاً یکی از شماره کارت‌های زیر را انتخاب کرده و مبلغ را واریز کنید:", reply_markup=card_keyboard)

    # پیام انتظار برای ارسال رسید
    await query.message.reply_text("📤 پس از واریز، رسید پرداخت را ارسال کنید.")

    # انتظار برای ارسال رسید از کاربر
    context.user_data['awaiting_receipt'] = package_id

# تابع انتخاب شماره کارت
async def select_card(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    query = update.callback_query
    card_index = int(query.data.split('_')[1])

    # افزایش تعداد استفاده از شماره کارت
    card_usage_count[card_index] += 1

    # بررسی تعداد استفاده از شماره کارت
    if card_usage_count[card_index] > 5:
        await query.message.reply_text("❗️ شماره کارت‌های موجود به پایان رسیده است. لطفاً به زودی دوباره تلاش کنید.")
        await query.message.reply_text("🔧 ربات در حال بروزرسانی است. لطفاً تا ساعاتی دیگر صبر کنید.")

        # اطلاع به مدیر (شماره مدیر باید اینجا قرار گیرد)
        # مدیریت ارسال اطلاعیه به مدیر
        # مدیر باید شماره کارت‌ها را به روز کند

        return

    await query.message.reply_text(f"شماره کارت انتخابی: {card_numbers[card_index]['number']}")

# تابع دریافت رسید
async def handle_receipt(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    if 'awaiting_receipt' in context.user_data:
        package_id = context.user_data['awaiting_receipt']
        receipt_photo = update.message.photo[-1]  # دریافت بزرگترین اندازه عکس
        receipt_id = update.message.message_id

        # ارسال اطلاعیه به مدیر برای تایید رسید
        manager_chat_id = '7304354618:AAGaYSXeBLFW_zPnbo3gW_oMOQz86CmjF4k'
        await context.bot.send_message(
            manager_chat_id,
            f"رسید جدید از کاربر {update.message.from_user.id} دریافت شد.\nشناسه رسید: {receipt_id}",
            reply_markup=InlineKeyboardMarkup([
                [InlineKeyboardButton(f"تایید رسید {receipt_id}", callback_data=f'approve_{receipt_id}')]
            ])
        )

        # پیام تایید دریافت رسید به کاربر
        await update.message.reply_text("رسید شما دریافت شد و در حال بررسی است. ✅")
        del context.user_data['awaiting_receipt']
    else:
        await update.message.reply_text("ابتدا یک پکیج را خریداری کنید.")

def main() -> None:
    application = Application.builder().token(TOKEN).build()

    # افزودن هندلرها
    application.add_handler(CommandHandler("start", start))
    application.add_handler(CallbackQueryHandler(package_details, pattern='^[1-6]$'))
    application.add_handler(CallbackQueryHandler(buy_package, pattern='^buy_'))
    application.add_handler(CallbackQueryHandler(select_card, pattern='^card_'))
    application.add_handler(MessageHandler(filters.PHOTO | filters.Document.ALL, handle_receipt))

    # شروع ربات
    loop = asyncio.get_event_loop()
    try:
        loop.run_until_complete(application.run_polling())
    finally:
        loop.close()

if __name__ == '__main__':
    main()
