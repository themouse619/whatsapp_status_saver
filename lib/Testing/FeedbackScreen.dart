import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_status_saver/Common/DummyData.dart' as dummyData;
import 'package:whatsapp_status_saver/Common/Constants.dart' as cnst;

class FeedbackScreen extends StatefulWidget {
  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  TextEditingController feedbackController = new TextEditingController();
  List feedbackOptions = [];

  clearAllFeedbackOptions() {
    for (int i = 0; i < dummyData.feedbackData["data"].length; i++) {
      setState(() {
        dummyData.feedbackData["data"][i]["value"] = false;
      });
    }
  }

  getFeedbackOptions(){
    for (int i = 0;
    i < dummyData.feedbackData['data'].length;
    i++) {
      if (dummyData.feedbackData['data'][i]['value'] == true) {
        feedbackOptions.add(
            dummyData.feedbackData['data'][i]['feedbackTitle']);
      }
    }
  }

  void _launchURL() async => await canLaunch(
          'mailto:${cnst.Constants.feedbackEmail}?subject=Feedback for Whatsapp Status Saver&body=Feedback Options:$feedbackOptions\nDescription:${feedbackController.text}')
      ? await launch(
          'mailto:${cnst.Constants.feedbackEmail}?subject=Feedback for Whatsapp Status Saver&body=Feedback Options:$feedbackOptions\nDescription:${feedbackController.text}')
      : throw 'Could not launch ${'mailto:${cnst.Constants.feedbackEmail}?subject=Feedback for Whatsapp Status Saver&body=Feedback Options:$feedbackOptions\nDescription:${feedbackController.text}'}';

  @override
  void initState() {
    super.initState();
    clearAllFeedbackOptions();
  }

  @override
  Widget build(BuildContext context) {
    print(dummyData.feedbackData["data"].length);
    return Scaffold(

      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: cnst.appPrimaryMaterialColor),
        title: Text(
          'Feedback',
          style: TextStyle(color: cnst.appPrimaryMaterialColor),
        ),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: SizedBox(
                  height: 280,
                  child: ListView.builder(
                      itemCount: dummyData.feedbackData["data"].length,
                      itemBuilder: (context, index) {
                        return CheckboxListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          checkColor: Colors.white,
                          activeColor: cnst.appPrimaryMaterialColor,
                          value: dummyData.feedbackData["data"][index]["value"],
                          onChanged: (val) {
                            setState(() {
                              dummyData.feedbackData["data"][index]["value"] =
                                  val;
                            });
                            // print(feedbackOptions);
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          title: Text(
                            dummyData.feedbackData["data"][index]
                                ["feedbackTitle"],
                            style: TextStyle(
                                color: cnst.appPrimaryMaterialColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                        );
                      }),
                ),
              ),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: TextFormField(
                  controller: feedbackController,
                  keyboardType: TextInputType.text,
                  maxLines: 7,
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontSize: 16, color: cnst.appPrimaryMaterialColor),
                  cursorColor: cnst.appPrimaryMaterialColor,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Describe your feedback",
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                      ),
                      contentPadding: EdgeInsets.only(
                        left: 10,
                        top: 8,
                        right: 10,
                        bottom: 8,
                      )),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              SizedBox(
                height: 45,
                width: 130,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  onPressed: () {
                    getFeedbackOptions();
                    print(feedbackOptions);
                    _launchURL();
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Feedback',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  color: cnst.appPrimaryMaterialColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
