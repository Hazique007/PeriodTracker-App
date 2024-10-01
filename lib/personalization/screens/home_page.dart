import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:periodtarckingapp/common/Texts/heading_text.dart';
import 'package:periodtarckingapp/common/appbar.dart';
import 'package:periodtarckingapp/personalization/controllers/periodController.dart';
import 'package:periodtarckingapp/personalization/screens/history.dart';
import 'package:periodtarckingapp/utils/colors/colors.dart';
import 'package:periodtarckingapp/utils/constants/size.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

void pickDate() async{
  DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2020),
    lastDate: DateTime(2100),
  );
  if (pickedDate != null) {
    controller.selectDate(pickedDate);
  }

}





   final controller = Get.put(PeriodController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: Text('Period Tracker'),
      ),
      body: Obx(
          ()=> Padding(padding: EdgeInsets.all(MySize.defaultSpace),
         child: SingleChildScrollView(
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [

             //Heading

             SectionHeading(title: 'Select your date',showActionButton: false,),
             SizedBox(height: MySize.spaceBtwItems,),

             //Container
             Container(
               width: double.infinity,
               height: 200,
               decoration: BoxDecoration(
                 color: MyColors.myBlue,
                 borderRadius: BorderRadius.circular(MySize.lg)
               ),
               child: Padding(
                 padding: const EdgeInsets.all(8.0),
                 child: Padding(
                   padding: const EdgeInsets.all(8.0),
                   child: Column(
                     children: [
                       Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           Container(
                             width: 220,
                             height: 80,
                             decoration: BoxDecoration(
                               borderRadius: BorderRadius.circular(MySize.cardRadiusLg),
                               color: Colors.grey.shade200
                             ),
                             child: Center(child: Text(
                                 controller.selectedDate.value != null ?

                               "${DateFormat('dd-MM-yyyy').format(controller.selectedDate.value!)}"
                               :"No date selected"

                               ,style:TextStyle(fontWeight: FontWeight.bold),))
                           ),

                           IconButton(onPressed:()=>pickDate()
                               , icon: Icon(Iconsax.calendar,size: 40,))
                         ],
                       ),

                       SizedBox(height: MySize.spaceBtwItems,),

                       SizedBox(
                           width: double.infinity,
                           child: ElevatedButton(onPressed:
                           (){
                             if(controller.selectedDate.value!=null){
                               controller.confirmDate();
                               Get.snackbar('Success', 'Date Confirmed ');
                               controller.selectedDate.value = null;


                             }else{

                               Get.snackbar('Failed', 'Try again ');
                             }


                           }

                               , child: Text('Confirm')))
                     ],
                   ),
                 ),
               ),
             ),

               SizedBox(height: MySize.spaceBtwSections,),

               SectionHeading(title: 'Your Dates',showActionButton: true,onPressed: ()=>Get.to(()=>HistoryPage()),),

               SizedBox(height: MySize.spaceBtwItems,),

               Container(
                 height: 160,
                 width: double.infinity,
                 decoration: BoxDecoration(
                   color: MyColors.mylightblue,
                   borderRadius: BorderRadius.circular(MySize.cardRadiusLg)
                 ),
                 child: Padding(
                   padding: const EdgeInsets.all(12.0),
                   child: Card(
                     elevation: 4,
                     shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(10),
                     ),
                     child: 
                     Column(
                       children: [
                         MyListTile(controller: controller),
                       ],
                     ),
                   ),
                 ),

               )





           ],),
         ),

        ),
      ),
    );
  }
}

class MyListTile extends StatelessWidget {
  const MyListTile({
    super.key,
    required this.controller,
  });

  final PeriodController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.date_range, color: Colors.blue),
          title: Text(
            "Next Period Date",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            DateFormat('dd-MM-yyyy').format(controller.nextPeriodDate.value),
            style: TextStyle(fontSize: 16),

          ),

        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(onPressed: controller.editAvailable.value?() async{
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: controller.selectedDate.value ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if(pickedDate!=null){
                controller.selectDate(pickedDate);
              }
            }:null, child: Text('Edit',style: TextStyle(color: controller.editAvailable.value? Colors.blue : Colors.grey),)),
            TextButton(onPressed: (){
              if(controller.selectedDate.value!=null){
                controller.confirmDate();
                Get.snackbar('Success', 'Date Confirmed ');
                controller.selectedDate.value=null;

              }

            }, child: Text('Confirm'))
          ],
        )

      ],
    );
  }
}
