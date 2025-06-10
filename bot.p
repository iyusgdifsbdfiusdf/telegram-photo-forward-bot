from telegram import Update
from telegram.ext import ApplicationBuilder, MessageHandler, filters, ContextTypes, CommandHandler

import os

TOKEN = os.getenv("7694030944:AAEbj7GcLNwjMtVMus-cAxoYvEF7mqkY9TE")
ADMIN_ID = int(os.getenv("7291303026"))

photo_owners = {}

async def start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    await update.message.reply_text("Send me a photo, and I'll send it to the admin.")

async def handle_photo(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user = update.effective_user
    photo = update.message.photo[-1]

    forwarded = await context.bot.forward_message(chat_id=ADMIN_ID, from_chat_id=update.message.chat.id, message_id=update.message.message_id)
    photo_owners[forwarded.message_id] = user.id

    await update.message.reply_text("Your photo was sent to the admin.")

async def handle_admin_reply(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if update.message.reply_to_message:
        replied_id = update.message.reply_to_message.message_id
        if replied_id in photo_owners:
            target_user_id = photo_owners[replied_id]
            if update.message.photo:
                await context.bot.send_photo(chat_id=target_user_id, photo=update.message.photo[-1].file_id, caption=update.message.caption or "")
            elif update.message.text:
                await context.bot.send_message(chat_id=target_user_id, text=update.message.text)

def main():
    app = ApplicationBuilder().token(TOKEN).build()
    app.add_handler(CommandHandler("start", start))
    app.add_handler(MessageHandler(filters.PHOTO, handle_photo))
    app.add_handler(MessageHandler(filters.ALL, handle_admin_reply))
    app.run_polling()

if __name__ == "__main__":
    main()
