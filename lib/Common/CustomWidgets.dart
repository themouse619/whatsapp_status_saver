import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:whatsapp_status_saver/Common/Constants.dart' as cnst;
import 'package:whatsapp_status_saver/en.dart';

class RaisedGradientButton extends StatelessWidget {
  final Widget child;
  final Gradient gradient;
  final double width;
  final double height;
  final Function onPressed;

  const RaisedGradientButton({
    Key key,
    @required this.child,
    this.gradient,
    this.width = double.infinity,
    this.height = 50.0,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 50.0,
      decoration: BoxDecoration(
          gradient: gradient,
          boxShadow: [
            BoxShadow(
              color: Colors.grey[500],
              offset: Offset(0.0, 1.5),
              blurRadius: 1.5,
            ),
          ],
          borderRadius: BorderRadius.circular(5)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
            onTap: onPressed,
            child: Center(
              child: child,
            )),
      ),
    );
  }
}

class RateUsPopUp extends StatefulWidget {
  double starRating;
  RateUsPopUp({this.starRating});
  @override
  _RateUsPopUpState createState() => _RateUsPopUpState();
}

class _RateUsPopUpState extends State<RateUsPopUp> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      backgroundColor: Colors.indigoAccent[200],
      title: Center(
        child: Text(
          RATE_US,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: cnst.appPrimaryMaterialColor,
            fontSize: 22,
            letterSpacing: 1.5,
          ),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            ENJOYING_THE_APP,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            RATE_YOUR_EXPERIENCE_USING_WHATSAPP_STATUS_SAVER_SO_FAR,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              // fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          RatingBar.builder(
            initialRating: 0,
            minRating: 1,
            direction: Axis.horizontal,
            glow: false,
            allowHalfRating: false,
            itemCount: 5,
            itemPadding: EdgeInsets.symmetric(horizontal: 8.0),
            itemBuilder: (context, _) => Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (rating) {
              print('rating is $rating');
              setState(() {
                widget.starRating=rating;
              });
            },
          ),
          SizedBox(height: 20,),
          SizedBox(
            height: 40,
            width: 120,
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              onPressed: () {
                Navigator.pop(context);
                Fluttertoast.showToast(
                    msg: RATING_SUBMITTED_SUCCESSFULLY,
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.SNACKBAR,
                    backgroundColor: cnst.appPrimaryMaterialColor.withOpacity(0.75),
                    textColor: Colors.white,
                    fontSize: 16.0);
              },
              child: Text(
                SUBMIT,
                style: TextStyle(color: cnst.appPrimaryMaterialColor, fontSize: 16),
              ),
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
