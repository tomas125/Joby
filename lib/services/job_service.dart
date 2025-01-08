import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job_model.dart';

class JobService {
  final CollectionReference _jobsCollection = FirebaseFirestore.instance.collection('jobs');

  Future<String> createJob(String userId, String workerId) async {
    final now = DateTime.now();
    final jobData = JobModel(
      id: '',
      userId: userId,
      workerId: workerId,
      createdAt: now,
      updatedAt: now,
    ).toMap();

    final docRef = await _jobsCollection.add(jobData);
    return docRef.id;
  }

  Future<void> updateJobStatus(String jobId, bool done, String description) async {
    await _jobsCollection.doc(jobId).update({
      'done': done,
      'description': description,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Stream<List<JobModel>> getJobs() {
    return _jobsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return JobModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
} 