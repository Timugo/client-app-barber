import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:timugo/src/models/services_model.dart';
import 'package:timugo/src/services/number_provider.dart';

class CardsServices extends StatelessWidget {
  const CardsServices({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    final size = MediaQuery.of(context).size;
    final servicesProvider = ServicesProvider();
    return FutureBuilder(
      future: servicesProvider.getServices(),
      builder: (BuildContext context, AsyncSnapshot<List<ServicesModel>> snapshot) {  
        if ( snapshot.hasData ) {
          final productos = snapshot.data;
          return Container(
            width: size.width,
            height: size.width>size.height ? size.height*0.60 :size.height*0.40 ,
            child: PageView.builder(
              controller: PageController(viewportFraction: size.width>size.height ? 0.4 : 0.7),
              pageSnapping: false,
              itemCount: productos.length,
              itemBuilder: (context, i) => _Card( productos[i] ), 
            ),
          );
        }else{
          return Center( child: CircularProgressIndicator());
        }
       }
    );
}
}

class _Card extends StatelessWidget {
  
   
 final  ServicesModel prod;
  _Card(this.prod);
   final url ='http://167.172.216.181:3000/';
  
  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;
    return Container(
      child: Stack(
        children: <Widget>[
          Row(
            children: <Widget>[
           //   _FirstDescription(prod),//lateral bar with description
              //SizedBox(width: 10.0),
              _DescriptionCard(prod),
            ],
          ),
         
          Positioned(
            top: size.width>size.height ? size.height*0.0 : size.height*0.0,
            bottom: size.width>size.height ? size.height*0.14 : size.height*0.11,
            left: size.width>size.height ? size.width*0.05 : size.width*0.09,
            //right:size.width>size.height ? size.width*0.05 : size.width*0.001,
            
            child: Image.network(url+prod.urlImg,
                                width: size.width>size.height ? size.height*0.22 : size.height*0.15,
                                height: size.width>size.height ? size.height*0.22 : size.height*0.15,
                                )
          )
          
        ],
      ),
    );
  }
}


class _DescriptionCard extends StatelessWidget {
  final ServicesModel prod;
 
  _DescriptionCard (this.prod);

 
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Card(  
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width:size.width>size.height ? size.height*0.40 :size.height*0.25, ///////////////////////////////////////
          height: size.height,
          color : Color(0xff000000),
          child: Column(

            children: <Widget>[

              //SizedBox(height: 30.0,),

              // RotatedBox(
              //   quarterTurns: 3,
              //   child: Column(
              //     mainAxisAlignment: MainAxisAlignment.end,
              //     children: <Widget>[
              //       Text('Style',style: TextStyle(color: Colors.white24,fontSize: 30,fontWeight: FontWeight.bold)),

              //     ],
              //   ),
              // ),
              Spacer(),
              Padding(
                padding: EdgeInsets.all(10),
                child: Row(
                  children: <Widget>[
                    Spacer(),
                    Text('${prod.name}',style: TextStyle(color: Colors.white,fontSize: 14,fontWeight: FontWeight.bold)),
                    Spacer(),
                    Icon(FontAwesomeIcons.heart,color: Colors.white),
                     
                  ],
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Container(
                    child: Text('\$'+'${prod.price}',style: TextStyle(color:Colors.white,fontWeight: FontWeight.bold),),
                    width: size.width>size.height ? size.width*0.1 : size.width*0.2,
                    //height: size.height*0.05,
                  ),
                  Container(
                    child: Center(
                      child: Text('Solicitar',style: TextStyle(color: Colors.white)),
                    ),
                    width: size.width>size.height ? size.width*0.11 : size.width*0.20,
                    height: size.width>size.height ? 50 : 40,
                    decoration:BoxDecoration(
                      color:Colors.red,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(15))

                    ) ,
                    
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );  
  }
}