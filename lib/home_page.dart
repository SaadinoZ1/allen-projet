import 'package:allen_hicham/pallete.dart';
import 'package:flutter/material.dart';



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context){

    return Scaffold(
      appBar: AppBar(
        title: const Text('Allen'),
        leading: const Icon(Icons.menu),
        centerTitle: true,
      ),
      body: Column(
        children: [Stack(
        children: [
          Center(
            child: Container(
                    height: 120,
                    width: 120 ,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: const  BoxDecoration(
            color: Pallete.assistantCircleColor,
            shape: BoxShape.circle,
                  ),
                ),
          )
      ],
    )],
    ),
    );

}}

