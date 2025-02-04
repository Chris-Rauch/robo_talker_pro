import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:robo_talker_pro/auxillary/enums.dart';
import 'package:robo_talker_pro/services/projectBloc/project_bloc.dart';
import 'package:robo_talker_pro/services/projectBloc/project_event.dart';
import 'package:robo_talker_pro/views/widgets/button.dart';

class SelectProjectView extends StatelessWidget {
  const SelectProjectView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Start a Project'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildButton(
                text: 'Late Payment',
                onPressed: () => {
                      context.read<ProjectBloc>().add(
                          const ProjectSelectedEvent(ProjectType.latePayment))
                    },
                height: 50,
                color: const Color(0xFF003366)),
            buildButton(
                text: 'Return Mail',
                onPressed: () => {
                      context.read<ProjectBloc>().add(
                          const ProjectSelectedEvent(ProjectType.returnMail))
                    },
                height: 50.0,
                color: Colors.grey),
            buildButton(
                text: 'Collection Calls',
                onPressed: () async => {
                      context.read<ProjectBloc>().add(
                          const ProjectSelectedEvent(ProjectType.collections))
                    },
                height: 50.0,
                color: const Color(0xFF003366)),
          ],
        ),
      ),
    );
  }
}
