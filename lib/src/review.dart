import 'package:app_review_helper/src/models/review_dialog_config.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';

/// If this [config] is set, the pre-dialog will be shown before showing the
/// request review dialog. Returns `true` if the review dialog is shown, `false`
/// will be shown otherwise.
Future<bool> review(ReviewDialogConfig? config) async {
  if (config == null) {
    await InAppReview.instance.requestReview();
    return true;
  }

  // Show the how do you feel dialog.
  final isUseful = await howYouFeelDialog(
    config.context,
    isUsefulText: config.isUsefulText,
    likeText: config.likeText,
    dislikeText: config.dislikeText,
  );

  if (isUseful == true) {
    await InAppReview.instance.requestReview();
    return true;
  }

  // Show the what can we do dialog.
  final context = config.context;
  if (config.whatCanWeDo != null && context.mounted) {
    final result = await whatCanWeDoDialog(
      context,
      cancelButtonText: config.cancelButtonText,
      submitButtonText: config.submitButtonText,
      whatCanWeDoText: config.whatCanWeDoText,
      anonymousText: config.anonymousText,
    );

    if (result != '') config.whatCanWeDo!(result);
  }

  return false;
}

/// Show the how do you feel dialog to ask user about their feeling. Returns `true`
/// if the user tap `Like`, `false` if the user tap `Dislike` and `null` when the
/// user tap `Cancel`.
Future<bool?> howYouFeelDialog(
  BuildContext context, {
  required String isUsefulText,
  required String likeText,
  required String dislikeText,
}) async {
  final isHowYouFeel = await showDialog<bool>(
    context: context,
    builder: (ctx) => Dialog(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isUsefulText,
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 110,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx, true);
                    },
                    icon: const Icon(Icons.thumb_up),
                    label: Text(likeText, style: const TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 20),
                SizedBox(
                  width: 110,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx, false);
                    },
                    icon: const Icon(Icons.thumb_down),
                    label:
                        Text(dislikeText, style: const TextStyle(fontSize: 12)),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );

  return isHowYouFeel;
}

/// Show the what can we do dialog if the user tap `Dislike` to get the user's
/// opinion how to improve the app.
Future<String> whatCanWeDoDialog(
  BuildContext context, {
  required String whatCanWeDoText,
  required String submitButtonText,
  required String cancelButtonText,
  required String anonymousText,
}) async {
  String text = '';
  final isSubmit = await showDialog<bool>(
    context: context,
    builder: (ctx) => Dialog(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              whatCanWeDoText,
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 8),
            TextField(
              onChanged: (newText) => text = newText,
              minLines: 3,
              maxLines: 6,
              autocorrect: false,
              style: const TextStyle(fontSize: 12),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(8.0),
                isDense: true,
              ),
            ),
            const SizedBox(height: 2),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                anonymousText,
                style: const TextStyle(
                  fontSize: 10,
                  // fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx, true);
                  },
                  child: Text(
                    submitButtonText,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx, false);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  child: Text(
                    cancelButtonText,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );

  if (isSubmit == true) return text;
  return '';
}
